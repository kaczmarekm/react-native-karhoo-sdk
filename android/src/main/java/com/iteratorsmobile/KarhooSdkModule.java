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
import com.facebook.react.bridge.WritableMap;
import com.karhoo.sdk.api.KarhooApi;
import com.karhoo.sdk.api.model.BraintreeSDKToken;
import com.karhoo.sdk.api.network.request.SDKInitRequest;
import com.karhoo.sdk.api.network.response.Resource;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

public class KarhooSdkModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    private static final int REQUEST_CODE = 1;
    private static final String EVENT_ACTIVITY_DOES_NOT_EXIST = "EVENT_ACTIVITY_DOES_NOT_EXIST";
    private static final String EVENT_CANCELLED = "EVENT_CANCELLED";
    private static final String EVENT_FAILED = "EVENT_FAILED";

    private final ReactApplicationContext reactContext;

    private Promise paymentForGuestPromise;

    public KarhooSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "KarhooSdk";
    }

    @ReactMethod
    public void initialize(String identifier, String referer, String organisationId) {
        KarhooConfiguration.initialize(this.reactContext, identifier, referer, organisationId);
    }

    @ReactMethod
    public void initializePaymentForGuest(String organisationId, String currency, final Promise promise) {
        final Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(EVENT_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
            return;
        }

        paymentForGuestPromise = promise;

        try {
            SDKInitRequest sdkInitRequest = new SDKInitRequest(organisationId, currency);
            KarhooApi.INSTANCE.getPaymentsService().initialisePaymentSDK(sdkInitRequest).execute(new Function1<Resource<? extends BraintreeSDKToken>, Unit>() {
                @Override
                public Unit invoke(Resource<? extends BraintreeSDKToken> resource) {
                    if (resource instanceof Resource.Success) {                        
                        String clientToken = ((Resource.Success<BraintreeSDKToken>) resource).getData().getToken();
                        DropInRequest dropInRequest = new DropInRequest().clientToken(clientToken);
                        currentActivity.startActivityForResult(dropInRequest.getIntent(reactContext), REQUEST_CODE);
                    } else {
                        paymentForGuestPromise.reject(EVENT_FAILED, ((Resource.Failure) resource).getError().getUserFriendlyMessage());
                        paymentForGuestPromise = null;
                    }
                    return Unit.INSTANCE;
                }
            });
        } catch (Exception e) {
            paymentForGuestPromise.reject(EVENT_FAILED, e);
            paymentForGuestPromise = null;
        }    
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                DropInResult result = data.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);
                PaymentMethodNonce nonce = result.getPaymentMethodNonce();
                WritableMap response = Arguments.createMap();
                response.putString("nonce", nonce != null ? nonce.getNonce() : null);
                paymentForGuestPromise.resolve(response);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                paymentForGuestPromise.reject(EVENT_CANCELLED, "Cancelled.");
            } else {
                Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
                paymentForGuestPromise.reject(EVENT_FAILED, error);
            }
        }
    }
}


