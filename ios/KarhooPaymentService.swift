import KarhooSDK
import BraintreeDropIn

class KarhooPaymentService {
    static let PAYMENT_NONCE_CANCELLED = "PAYMENT_NONCE_CANCELLED";
    static let PAYMENT_NONCE_FAILED = "PAYMENT_NONCE_FAILED";

    static func getPaymentNonce(_ organisationId: String, paymentData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo
            .getPaymentService()
            .initialisePaymentSDK(paymentSDKTokenPayload: PaymentSDKTokenPayload(organisationId: organisationId, currency: paymentData["currency"] as! String))
            .execute { result in
                switch result {
                    case .success(let result, let correlationId):
                        let amountString = paymentData["amount"] as! String
                        let amountDecimal = Decimal(string: amountString)
                        
                        if (amountDecimal == nil) {
                            let errorDict: NSDictionary = [
                                "error": "PaymentData.amount not formatted correclty",
                                "correlationId": correlationId!
                            ]
                            reject(KarhooPaymentService.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
                            return;
                        }
                        
                        let amountNSDecimalNumber = NSDecimalNumber(decimal: amountDecimal!)
                        
                        let threeDSecureRequest = BTThreeDSecureRequest()
                        threeDSecureRequest.amount = amountNSDecimalNumber
                        threeDSecureRequest.versionRequested = .version2
                        
                        let dropInRequest = BTDropInRequest()
                        dropInRequest.threeDSecureRequest = threeDSecureRequest
                        
                        let dropIn = BTDropInController(authorization: result.token, request: dropInRequest) {
                            (controller, result, error) in
                                if (error != nil) {
                                    let errorDict: NSDictionary = [
                                        "error": "Unknown error",
                                        "correlationId": correlationId!
                                    ]
                                    reject(KarhooPaymentService.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
                                    controller.dismiss(animated: true, completion: nil)
                                } else if (result?.isCanceled == true) {
                                    let errorDict: NSDictionary = [
                                        "error": "Cancelled by user",
                                        "correlationId": correlationId!
                                    ]
                                    reject(KarhooPaymentService.PAYMENT_NONCE_CANCELLED, nil, errorDict as? Error)
                                    controller.dismiss(animated: true, completion: nil)
                                } else if let result = result {
                                    let nonce = result.paymentMethod?.nonce
                                    let resultDict: NSDictionary = [
                                        "nonce": nonce!,
                                        "correlationId": correlationId!
                                    ]
                                    resolve(resultDict)
                                    controller.dismiss(animated: true, completion: nil)
                                }
                        }
                        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
                        rootViewController?.present(dropIn!, animated: true, completion: nil)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooPaymentService.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
                }
            }
    }
}
