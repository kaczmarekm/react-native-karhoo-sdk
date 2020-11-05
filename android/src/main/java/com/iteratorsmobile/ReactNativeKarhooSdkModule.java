package com.iteratorsmobile;

import android.util.Log;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.karhoo.sdk.api.KarhooApi;

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
        Log.d("XXX", "identifier: " + identifier + ", " + "referer: " + referer + ", " + organisationId);
        KarhooApi.setConfiguration(new KarhooConfig(this.reactContext));
    }
}


