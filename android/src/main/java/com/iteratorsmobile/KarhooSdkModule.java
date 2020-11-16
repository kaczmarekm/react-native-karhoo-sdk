package com.iteratorsmobile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.braintreepayments.api.BraintreeFragment;
import com.braintreepayments.api.ThreeDSecure;
import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;
import com.braintreepayments.api.interfaces.BraintreeErrorListener;
import com.braintreepayments.api.interfaces.PaymentMethodNonceCreatedListener;
import com.braintreepayments.api.interfaces.ThreeDSecureLookupListener;
import com.braintreepayments.api.models.PaymentMethodNonce;
import com.braintreepayments.api.models.ThreeDSecureLookup;
import com.braintreepayments.api.models.ThreeDSecureRequest;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.karhoo.sdk.analytics.AnalyticProvider;
import com.karhoo.sdk.api.KarhooApi;
import com.karhoo.sdk.api.KarhooEnvironment;
import com.karhoo.sdk.api.KarhooSDKConfiguration;
import com.karhoo.sdk.api.model.AuthenticationMethod;
import com.karhoo.sdk.api.model.BraintreeSDKToken;
import com.karhoo.sdk.api.model.CardType;
import com.karhoo.sdk.api.model.PaymentsNonce;
import com.karhoo.sdk.api.model.TripInfo;
import com.karhoo.sdk.api.network.request.PassengerDetails;
import com.karhoo.sdk.api.network.request.Passengers;
import com.karhoo.sdk.api.network.request.SDKInitRequest;
import com.karhoo.sdk.api.network.request.TripBooking;
import com.karhoo.sdk.api.network.response.Resource;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.Collections;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;


public class KarhooSdkModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    protected static final int PAYMENT_NONCE_REQUEST_CODE = 1;
    protected static final String EVENT_ACTIVITY_DOES_NOT_EXIST = "EVENT_ACTIVITY_DOES_NOT_EXIST";
    protected static final String EVENT_CANCELLED = "EVENT_CANCELLED";
    protected static final String EVENT_FAILED = "EVENT_FAILED";
    protected static final String BOOKING_FAILED = "BOOKING_FAILED";

    private final ReactApplicationContext reactContext;

    private Promise paymentNoncePromise;

    private static String amount;
    private static String braintreeSdkToken;

    public KarhooSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "KarhooSdk";
    }

    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if (requestCode == PAYMENT_NONCE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                try {
                    DropInResult dropInResult = data.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);
                    PaymentMethodNonce paymentMethodNonce = dropInResult.getPaymentMethodNonce();

                    PaymentsNonce paymentsNonce = convertToPaymentsNonce(paymentMethodNonce);
                    threeDSecureNonce(paymentsNonce);

//                    CardNonce cardNonce = (CardNonce) paymentMethodNonce;
//                    if (cardNonce != null) {
//                        if (cardNonce.getThreeDSecureInfo().isLiabilityShifted()) {
//                            Log.d("XXX", "liability shifted");
//                            WritableMap response = Arguments.createMap();
//                            response.putString("nonce", paymentMethodNonce.getNonce());
//                            paymentNoncePromise.resolve(response);
//                            clearData();
//                        } else if (cardNonce.getThreeDSecureInfo().isLiabilityShiftPossible()) {
//                            Log.d("XXX", "liability shift possible");
//                            threeDSecureNonce(paymentMethodNonce);
//                        } else {
//                            Log.d("XXX", "liability shift impossible");
//                            paymentNoncePromise.reject(EVENT_FAILED, "Liability shift not possible.");
//                        }
//                    } else {
//                        paymentNoncePromise.reject(EVENT_FAILED, "Error occurred while getting payment nonce.");
//                    }
                } catch (Exception e) {
                    paymentNoncePromise.reject(EVENT_FAILED, e);
                    clearData();
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                paymentNoncePromise.reject(EVENT_CANCELLED, "Cancelled.");
                clearData();
            } else {
                Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
                paymentNoncePromise.reject(EVENT_FAILED, error);
                clearData();
            }
        }
    }

    public void onNewIntent(Intent intent) {}

    @ReactMethod
    public void initialize(final String identifier, final String referer, final String organisationId) {
        KarhooApi.INSTANCE.setConfiguration(new KarhooSDKConfiguration() {
            @NotNull
            @Override
            public KarhooEnvironment environment() {
                return new KarhooEnvironment.Sandbox();
            }

            @NotNull
            @Override
            public Context context() {
                return getCurrentActivity();
            }

            @NotNull
            @Override
            public AuthenticationMethod authenticationMethod() {
                return new AuthenticationMethod.Guest(identifier, referer, organisationId);
            }

            @Nullable
            @Override
            public AnalyticProvider analyticsProvider() {
                return null;
            }
        });
    }

    @ReactMethod
    public void getPaymentNonce(final String organisationId, final ReadableMap paymentData, final Promise promise) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                final Activity currentActivity = getCurrentActivity();
                KarhooSdkModule.setAmount(paymentData.getString("amount"));

                if (currentActivity == null) {
                    promise.reject(EVENT_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
                    clearData();
                    return;
                }

                paymentNoncePromise = promise;

                try {
                    SDKInitRequest sdkInitRequest = new SDKInitRequest(organisationId, paymentData.getString("currency"));
                    KarhooApi.INSTANCE.getPaymentsService().initialisePaymentSDK(sdkInitRequest).execute(
                            new Function1<Resource<? extends BraintreeSDKToken>, Unit>() {
                                @Override
                                public Unit invoke(Resource<? extends BraintreeSDKToken> resource) {
                                    if (resource instanceof Resource.Success) {
                                        String token = ((Resource.Success<BraintreeSDKToken>) resource).getData().getToken();
                                        KarhooSdkModule.setBraintreeToken(token);
//                                        ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest()
//                                                .amount(KarhooSdkModule.amount)
//                                                .versionRequested(ThreeDSecureRequest.VERSION_2);
                                        DropInRequest dropInRequest = new DropInRequest()
                                                .clientToken(token);
//                                        .requestThreeDSecureVerification(true)
//                                        .threeDSecureRequest(threeDSecureRequest);
                                        currentActivity.startActivityForResult(dropInRequest.getIntent(reactContext), PAYMENT_NONCE_REQUEST_CODE);
                                    } else {
                                        paymentNoncePromise.reject(EVENT_FAILED, ((Resource.Failure) resource).getError().getUserFriendlyMessage());
                                        paymentNoncePromise = null;
                                        clearData();
                                    }
                                    return Unit.INSTANCE;
                                }
                            }
                    );
                } catch (Exception e) {
                    paymentNoncePromise.reject(EVENT_FAILED, e);
                    paymentNoncePromise = null;
                    clearData();
                }
            }
        });
    }

    @ReactMethod
    public void bookTrip(ReadableMap passenger, String quoteId, String paymentNonce, final Promise promise) {
        try {
            List<PassengerDetails> passengersList = Collections.singletonList(new PassengerDetails(
                    passenger.getString("firstName"),
                    passenger.getString("lastName"),
                    passenger.getString("email"),
                    passenger.getString("mobileNumber"),
                    passenger.getString("locale")
            ));
            Passengers passengers = new Passengers(0, passengersList);
            TripBooking tripBooking = new TripBooking(quoteId, passengers, null, null, paymentNonce);
            KarhooApi.INSTANCE.getTripService().book(tripBooking).execute(
                    new Function1<Resource<? extends TripInfo>, Unit>() {
                        @Override
                        public Unit invoke(Resource<? extends TripInfo> resource) {
                            if (resource instanceof Resource.Success) {
                                String tripId = ((Resource.Success<TripInfo>) resource).getData().getTripId();
                                WritableMap response = Arguments.createMap();
                                response.putString("tripId", tripId);
                                promise.resolve(response);
                            } else {
                                promise.reject(BOOKING_FAILED, ((Resource.Failure) resource).getError().getUserFriendlyMessage());
                            }
                            return Unit.INSTANCE;
                        }
                    }
            );
        } catch (Exception e) {
            promise.reject(BOOKING_FAILED, e);
        }
    }

    private PaymentsNonce convertToPaymentsNonce(PaymentMethodNonce paymentMethodNonce) {
        return new PaymentsNonce(
                paymentMethodNonce.getNonce(),
                CardType.valueOf(paymentMethodNonce.getTypeLabel().toUpperCase()),
                paymentMethodNonce.getDescription()
        );
    }

    private static void setAmount(String amount) {
        KarhooSdkModule.amount = amount;
    }

    private static void setBraintreeToken(String token) {
        KarhooSdkModule.braintreeSdkToken = token;
    }

    private static void clearData() {
        KarhooSdkModule.amount = null;
        KarhooSdkModule.braintreeSdkToken = null;
    }

    private void threeDSecureNonce(PaymentsNonce paymentMethodNonce) {
        try {
            final BraintreeFragment braintreeFragment = BraintreeFragment.newInstance((AppCompatActivity) getCurrentActivity(), KarhooSdkModule.braintreeSdkToken);
            braintreeFragment.addListener(new PaymentMethodNonceCreatedListener() {
                @Override
                public void onPaymentMethodNonceCreated(PaymentMethodNonce paymentMethodNonce) {
                    Log.d("XXX", paymentMethodNonce.getNonce());
                    WritableMap response = Arguments.createMap();
                    response.putString("nonce", paymentMethodNonce.getNonce());
                    paymentNoncePromise.resolve(response);
                    clearData();
                }
            });
            braintreeFragment.addListener(new BraintreeErrorListener() {
                @Override
                public void onError(Exception error) {
                    Log.d("XXX onError", error.getMessage(), error);
                    paymentNoncePromise.reject(EVENT_FAILED, error);
                    clearData();
                }
            });
            ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest()
                    .nonce(paymentMethodNonce.getNonce())
                    .amount(KarhooSdkModule.amount)
                    .versionRequested(ThreeDSecureRequest.VERSION_2);
            ThreeDSecure.performVerification(braintreeFragment, threeDSecureRequest, new ThreeDSecureLookupListener() {
                @Override
                public void onLookupComplete(ThreeDSecureRequest request, ThreeDSecureLookup lookup) {
                    ThreeDSecure.continuePerformVerification(braintreeFragment, request, lookup);
                    Log.d("XXX", "onLookupComplete " + lookup.getCardNonce().getThreeDSecureInfo().isLiabilityShifted() + " / " + lookup.getCardNonce().getThreeDSecureInfo().isLiabilityShiftPossible());
                }
            });
        } catch (Exception e) {
            paymentNoncePromise.reject(EVENT_FAILED, e);
            Log.d("XXX exception", e.getMessage(), e);
            clearData();
        }
    }
}