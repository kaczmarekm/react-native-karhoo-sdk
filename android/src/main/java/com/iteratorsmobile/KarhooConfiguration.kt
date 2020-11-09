package com.iteratorsmobile;

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.ReactContext
import com.karhoo.sdk.analytics.AnalyticProvider
import com.karhoo.sdk.api.KarhooApi
import com.karhoo.sdk.api.KarhooEnvironment
import com.karhoo.sdk.api.KarhooSDKConfiguration
import com.karhoo.sdk.api.model.AuthenticationMethod

class KarhooConfiguration(
    private val context: ReactContext, 
    private val identifier: String, 
    private val referer: String, 
    private val organisationId: String
) : KarhooSDKConfiguration {

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
        return AuthenticationMethod.Guest(identifier = this.identifier, referer = this.referer, organisationId = this.organisationId)
    }

    companion object {
        @kotlin.jvm.JvmStatic
        fun initialize(context: ReactContext, identifier : String, referer: String, organisationId: String) {
            KarhooApi.setConfiguration(configuration = KarhooConfiguration(context = context, identifier = identifier, referer = referer, organisationId = organisationId));              
        }
    }
}