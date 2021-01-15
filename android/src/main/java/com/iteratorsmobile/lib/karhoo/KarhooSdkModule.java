package com.iteratorsmobile.lib.karhoo;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;
import com.braintreepayments.api.models.CardNonce;
import com.braintreepayments.api.models.PaymentMethodNonce;
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
import com.karhoo.sdk.api.model.CancellationReason;
import com.karhoo.sdk.api.model.TripInfo;
import com.karhoo.sdk.api.network.request.Luggage;
import com.karhoo.sdk.api.network.request.PassengerDetails;
import com.karhoo.sdk.api.network.request.Passengers;
import com.karhoo.sdk.api.network.request.SDKInitRequest;
import com.karhoo.sdk.api.network.request.TripBooking;
import com.karhoo.sdk.api.network.request.TripCancellation;
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
    protected static final String TRIP_CANCEL_FAILED = "TRIP_CANCEL_FAILED";


    private final ReactApplicationContext reactContext;

    private Promise paymentNoncePromise;

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

                    CardNonce cardNonce = (CardNonce) paymentMethodNonce;
                    if (cardNonce != null) {
                        if (cardNonce.getThreeDSecureInfo().isLiabilityShifted()) {
                            WritableMap response = Arguments.createMap();
                            response.putString("nonce", paymentMethodNonce.getNonce());
                            paymentNoncePromise.resolve(response);
                        } else {
                            paymentNoncePromise.reject(EVENT_FAILED, "Liability shift not possible.");
                        }
                    } else {
                        paymentNoncePromise.reject(EVENT_FAILED, "Error occurred while getting payment nonce.");
                    }
                } catch (Exception e) {
                    paymentNoncePromise.reject(EVENT_FAILED, e);
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                paymentNoncePromise.reject(EVENT_CANCELLED, "Cancelled.");
            } else {
                Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
                paymentNoncePromise.reject(EVENT_FAILED, error);
            }
        }
    }

    public void onNewIntent(Intent intent) {}

    @ReactMethod
    public void initialize(final String identifier, final String referer, final String organisationId, final boolean isProduction) {
        KarhooApi.INSTANCE.setConfiguration(new KarhooSDKConfiguration() {
            @NotNull
            @Override
            public KarhooEnvironment environment() {
                return isProduction ? new KarhooEnvironment.Production() : new KarhooEnvironment.Sandbox();
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

                if (currentActivity == null) {
                    promise.reject(EVENT_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
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
                                        ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest()
                                                .amount(paymentData.getString("amount"))
                                                .versionRequested(ThreeDSecureRequest.VERSION_2);
                                        DropInRequest dropInRequest = new DropInRequest()
                                                .clientToken(token)
                                                .requestThreeDSecureVerification(true)
                                                .threeDSecureRequest(threeDSecureRequest);
                                        currentActivity.startActivityForResult(dropInRequest.getIntent(reactContext), PAYMENT_NONCE_REQUEST_CODE);
                                    } else {
                                        paymentNoncePromise.reject(EVENT_FAILED, ((Resource.Failure) resource).getError().getUserFriendlyMessage());
                                        paymentNoncePromise = null;
                                    }
                                    return Unit.INSTANCE;
                                }
                            }
                    );
                } catch (Exception e) {
                    paymentNoncePromise.reject(EVENT_FAILED, e);
                    paymentNoncePromise = null;
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
            Luggage luggage = new Luggage(0);
            Passengers passengers = new Passengers(0, passengersList, luggage);
            TripBooking tripBooking = new TripBooking(null, null, null, null, passengers, null, paymentNonce, null, null, null, 0, quoteId);
            KarhooApi.INSTANCE.getTripService().book(tripBooking).execute(
                    new Function1<Resource<? extends TripInfo>, Unit>() {
                        @Override
                        public Unit invoke(Resource<? extends TripInfo> resource) {
                            if (resource instanceof Resource.Success) {
                                String tripId = ((Resource.Success<TripInfo>) resource).getData().getTripId();
                                String followCode = ((Resource.Success<TripInfo>) resource).getData().getFollowCode();
                                WritableMap response = Arguments.createMap();
                                response.putString("tripId", tripId);
                                response.putString("followCode", followCode);
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

    @ReactMethod
    public void cancelTrip(String tripId, final Promise promise) {
        try {
            TripCancellation tripCancellation = new TripCancellation(tripId, CancellationReason.OTHER_USER_REASON, "");
            KarhooApi.INSTANCE.getTripService().cancel(tripCancellation).execute(
                   new Function1<Resource<? extends Void>, Unit>() {
                       @Override
                       public Unit invoke(Resource<? extends Void> resource) {
                           if (resource instanceof Resource.Success) {
                               WritableMap response = Arguments.createMap();
                               response.putBoolean("tripCancelled", true);
                               promise.resolve(response);
                           } else {
                               promise.reject(TRIP_CANCEL_FAILED, ((Resource.Failure) resource).getError().getUserFriendlyMessage());
                           }
                           return Unit.INSTANCE;
                       }
                   }
            );

        } catch (Exception e) {
            promise.reject(TRIP_CANCEL_FAILED, e);
        }
    } 
}