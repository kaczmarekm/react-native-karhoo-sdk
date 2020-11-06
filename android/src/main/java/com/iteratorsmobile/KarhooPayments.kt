package com.iteratorsmobile;

import android.support.v7.app.AppCompatActivity
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.braintreepayments.api.BraintreeFragment
import com.braintreepayments.api.ThreeDSecure
import com.braintreepayments.api.dropin.DropInRequest
import com.braintreepayments.api.dropin.DropInResult
import com.braintreepayments.api.models.PaymentMethodNonce
import com.facebook.react.bridge.ReactContext
import com.karhoo.sdk.api.KarhooApi
import com.karhoo.sdk.api.datastore.user.SavedPaymentInfo
import com.karhoo.sdk.api.model.AuthenticationMethod
import com.karhoo.sdk.api.model.PaymentsNonce
import com.karhoo.sdk.api.model.Quote
import com.karhoo.sdk.api.network.request.NonceRequest
import com.karhoo.sdk.api.network.request.PassengerDetails
import com.karhoo.sdk.api.network.request.PassengerDetails
import com.karhoo.sdk.api.network.request.Payer
import com.karhoo.sdk.api.network.request.SDKInitRequest
import com.karhoo.sdk.api.network.response.Resource
import com.braintreepayments.api.ThreeDSecure
import com.karhoo.sdk.api.model.UserInfo
import com.braintreepayments.api.models.ThreeDSecureRequest
import com.braintreepayments.api.interfaces.BraintreeErrorListener
import java.util.*

class KarhooPayments {
    companion object {
        const val REQ_CODE_BRAINTREE = 301
        const val REQ_CODE_BRAINTREE_GUEST = 302

        private var reactContext: ReactContext? = null    

        @kotlin.jvm.JvmStatic
        fun initializePaymentForGuest(context: ReactContext, organisationId: String, currency: String, firstName: String, lastName: String, phoneNumber: String, email: String, locale: String) {
            reactContext = context
            val sdkInitRequest = SDKInitRequest(
                    organisationId = organisationId,
                    currency = currency
            )
            KarhooApi.paymentsService.initialisePaymentSDK(sdkInitRequest).execute { result ->
                when (result) {
                    is Resource.Success -> {
                        val passengerDetails = PassengerDetails(
                            firstName = firstName,
                            lastName = lastName,
                            phoneNumber = phoneNumber,
                            email = email,
                            locale = locale
                        )
                        getNonceForGuest(result.data.token, passengerDetails)
                    }
                    is Resource.Failure -> {
                        Log.e("XXX", result.error.userFriendlyMessage)
                    }
                }
            }
        }

        private fun getNonceForGuest(braintreeSDKToken: String, passengerDetails: PassengerDetails) {
            paymentsNonce?.let {
                threeDSecureNonce(
                    braintreeSDKToken,
                    it,
                    quotePriceToAmount(quote),
                    passengerDetails                    
                )
            }
        }

        private fun getNonceForUser(braintreeSDKToken: String, passengerDetails: PassengerDetails) {           
            this.braintreeSDKToken = braintreeSDKToken
            val user = KarhooApi.userStore.currentUser
            val nonceRequest = NonceRequest(
                payer = getPayerDetails(user),
                organisationId = user.organisations.first().id
            )
            KarhooApi.paymentsService.getNonce(nonceRequest).execute { result ->
                when (result) {
                    is Resource.Success -> {
                        Log.d("XXX", "nonce")
                    }
                    is Resource.Failure -> {
                        Log.e("XXX", "nonce failure")
                    }
                }
            }            
        }

        private fun isGuest() = config.authenticationMethod() is AuthenticationMethod.Guest    

        fun threeDSecureNonce(braintreeSDKToken: String, paymentsNonce: PaymentsNonce, amount: String, passengerDetails: PassengerDetails) {   
            val braintreeFragment = BraintreeFragment.newInstance(context as AppCompatActivity, braintreeSDKToken)

            braintreeFragment.addListener(object : PaymentMethodNonceCreatedListener {
                override fun onPaymentMethodNonceCreated(paymentMethodNonce: PaymentMethodNonce?) {
                    passBackThreeDSecuredNonce(
                        paymentMethodNonce,
                        passengerDetails,
                        ""
                    )
                }
            })

            braintreeFragment.addListener(
                object : BraintreeErrorListener {
                    override fun onError(error: Exception?) {
                        showPaymentDialog(braintreeSDKToken)
                    }
                }
            )

            val threeDSecureRequest = ThreeDSecureRequest()
                    .nonce(paymentsNonce.nonce)
                    .amount(amount)
                    .versionRequested(ThreeDSecureRequest.VERSION_2)

            ThreeDSecure.performVerification(braintreeFragment, threeDSecureRequest) { request, lookup ->
                ThreeDSecure.continuePerformVerification(braintreeFragment, request, lookup)
            }
        }

        private fun getPayerDetails(user: UserInfo): Payer =
            Payer(
                id = user.userId,
                email = user.email,
                firstName = user.firstName,
                lastName = user.lastName
            )
        
        fun showPaymentDialog(braintreeSDKToken: String) {
            AlertDialog.Builder(context, R.style.DialogTheme)
                    .setTitle(R.string.payment_issue)
                    .setMessage(R.string.payment_issue_message)
                    .setPositiveButton(R.string.add_card) { dialog, _ ->
                        showPaymentUI(braintreeSDKToken)
                        dialog.dismiss()
                    }
                    .setNegativeButton(R.string.cancel) { dialog, _ ->
                        dialog.dismiss()
                    }
                    .show()
        }
    }
}