package com.iteratorsmobile;

import android.content.Context
import com.facebook.react.bridge.ReactContext
import com.karhoo.sdk.analytics.AnalyticProvider
import com.karhoo.sdk.api.KarhooApi
import com.karhoo.sdk.api.KarhooEnvironment
import com.karhoo.sdk.api.KarhooSDKConfiguration
import com.karhoo.sdk.api.model.AuthenticationMethod

class KarhooConfiguration(context: ReactContext) : KarhooSDKConfiguration {
    override fun environment(): KarhooEnvironment {
        return KarhooEnvironment.Sandbox()
    }

    override fun context(): Context {
        return context
    }

    override fun analyticsProvider(): AnalyticProvider? {
        return null
    }

    override fun authenticationMethod(): AuthenticationMethod {
        return AuthenticationMethod.KarhooUser()
    }

    companion object {
        @kotlin.jvm.JvmStatic
        fun initialize(context: ReactContext) {
            KarhooApi.setConfiguration(configuration = KarhooConfiguration(context = context));
        }
    }
}