package com.iteratorsmobile;

import android.app.Activity;
import android.content.Intent;
import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;
import com.braintreepayments.api.models.PaymentMethodNonce;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.karhoo.sdk.api.KarhooApi;
import com.karhoo.sdk.api.model.BraintreeSDKToken;
import com.karhoo.sdk.api.model.TripInfo;
import com.karhoo.sdk.api.network.request.PassengerDetails;
import com.karhoo.sdk.api.network.request.Passengers;
import com.karhoo.sdk.api.network.request.SDKInitRequest;
import com.karhoo.sdk.api.network.request.TripBooking;
import com.karhoo.sdk.api.network.response.Resource;

import java.util.Collections;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

public class KarhooSdkModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    private static final int REQUEST_CODE = 1;
    private static final String EVENT_ACTIVITY_DOES_NOT_EXIST = "EVENT_ACTIVITY_DOES_NOT_EXIST";
    private static final String EVENT_CANCELLED = "EVENT_CANCELLED";
    private static final String EVENT_FAILED = "EVENT_FAILED";
    private static final String BOOKING_FAILED = "BOOKING_FAILED";

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
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                DropInResult result = data.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);
                PaymentMethodNonce nonce = result.getPaymentMethodNonce();
                WritableMap response = Arguments.createMap();
                response.putString("nonce", nonce != null ? nonce.getNonce() : null);
                paymentNoncePromise.resolve(response);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                paymentNoncePromise.reject(EVENT_CANCELLED, "Cancelled.");
            } else {
                Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
                paymentNoncePromise.reject(EVENT_FAILED, error);
            }
        }
    }

    public void onNewIntent(Intent intent) {
    }

    @ReactMethod
    public void initialize(String identifier, String referer, String organisationId) {
        KarhooConfiguration.initialize(this.reactContext, identifier, referer, organisationId);
    }

    @ReactMethod
    public void getPaymentNonce(String organisationId, String currency, final Promise promise) {
        final Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(EVENT_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
            return;
        }

        paymentNoncePromise = promise;

        try {
            SDKInitRequest sdkInitRequest = new SDKInitRequest(organisationId, currency);
            KarhooApi.INSTANCE.getPaymentsService().initialisePaymentSDK(sdkInitRequest).execute(
                    new Function1<Resource<? extends BraintreeSDKToken>, Unit>() {
                        @Override
                        public Unit invoke(Resource<? extends BraintreeSDKToken> resource) {
                            if (resource instanceof Resource.Success) {
                                String clientToken = ((Resource.Success<BraintreeSDKToken>) resource).getData().getToken();
                                DropInRequest dropInRequest = new DropInRequest().clientToken(clientToken);
                                currentActivity.startActivityForResult(dropInRequest.getIntent(reactContext), REQUEST_CODE);
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

    @ReactMethod
    public void bookTrip(ReadableMap userInfo, String quoteId, String paymentNonce, final Promise promise) {
        try {
            List<PassengerDetails> passengersList = Collections.singletonList(new PassengerDetails(
                    userInfo.getString("firstName"),
                    userInfo.getString("lastName"),
                    userInfo.getString("email"),
                    userInfo.getString("mobileNumber"),
                    userInfo.getString("locale")
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
}