package com.iteratorsmobile;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class ReactNativeKarhooSdkModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public ReactNativeKarhooSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "ReactNativeKarhooSdk";
    }

    @ReactMethod
    public void initialize(String identifier, String referer, String organisationId) {
        KarhooConfiguration.initialize(this.reactContext, identifier, referer, organisationId);
    }

    @ReactMethod
    public void initializePaymentForGuest(String organisationId, String currency) {
        KarhooPayments.initializePaymentForGuest(this.reactContext, organisationId, currency);
    }
}


