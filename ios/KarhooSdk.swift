import KarhooSDK
import BraintreeDropIn
import Braintree

@objc(KarhooSdk)
class KarhooSdk: NSObject {
    @objc(initialize:referer:organisationId:)
    func initialize(identifier: String, referer: String, organisationId: String) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId))
    }

    @objc(initializePaymentForGuest:currency:resolver:rejecter:)
    func initializePaymentForGuest(organisationId: String, currency: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo.getPaymentService().initialisePaymentSDK(paymentSDKTokenPayload: PaymentSDKTokenPayload(organisationId: organisationId, currency: currency))
            .execute { result in
                switch result {
                    case .success(let sdk):
                        let request =  BTDropInRequest()
                        let dropIn = BTDropInController(authorization: sdk.token, request: request) {
                            (controller, result, error) in
                                if (error != nil) {
                                    print("KarhooSdk ERROR")
                                    controller.dismiss(animated: true, completion: nil)                            
                                    reject(nil, nil, nil)
                                } else if (result?.isCancelled == true) {
                                    print("KarhooSdk CANCELLED")
                                    controller.dismiss(animated: true, completion: nil)                            
                                    reject(nil, nil, nil)
                                } else if let result = result {
                                    print("KarhooSdk SUCCESS")
                                    var nonce = result.paymentMethod?.nonce
                                    var resultDict: NSDictionary = [   
                                        "nonce": nonce!,                                                                     
                                    ]
                                    controller.dismiss(animated: true, completion: nil)     
                                    resolve(resultDict)                       
                                }
                        }
                        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
                        rootViewController?.present(dropIn!, animated: true, completion: nil)
                    case .failure(let error):
                        print("KarhooSdk ERROR: \(error?.code) \(error?.message)")
                }
            }
    }
}

struct KarhooConfiguration: KarhooSDKConfiguration {
    var identifier: String
    var referer: String
    var organisationId: String

    init (identifier: String, referer: String, organisationId: String) {
        self.identifier = identifier
        self.referer = referer
        self.organisationId = organisationId
    }

    func environment() -> KarhooEnvironment {
        return .sandbox
    }

    func authenticationMethod() -> AuthenticationMethod {
        return .guest(settings: GuestSettings(identifier: self.identifier, referer: self.referer, organisationId: self.organisationId))
    }
}
