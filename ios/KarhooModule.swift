import KarhooSDK
import BraintreeDropIn
import Braintree

@objc(KarhooModule)
class KarhooModule: UIViewController {
    @objc(initialize:referer:organisationId:)
    func initialize(identifier: String, referer: String, organisationId: String) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId))
    }

    @objc(initializePaymentForGuest:currency:)
    func initializePaymentForGuest(organisationId: String, currency: String) -> Void {
        Karhoo.getPaymentService().initialisePaymentSDK(paymentSDKTokenPayload: PaymentSDKTokenPayload(organisationId: organisationId, currency: currency))
            .execute { result in
                switch result {
                case .success(let sdk):
                    let request =  BTDropInRequest()
                    let dropIn = BTDropInController(authorization: sdk.token, request: request)
                        { (controller, result, error) in
                            if (error != nil) {
                                print("ERROR")
                            } else if (result?.isCancelled == true) {
                                print("CANCELLED")
                            } else if let result = result {
                                // Use the BTDropInResult properties to update your UI
                                let selectedPaymentOptionType = result.paymentOptionType
                                let selectedPaymentMethod = result.paymentMethod
                                let selectedPaymentMethodIcon = result.paymentIcon
                                let selectedPaymentMethodDescription = result.paymentDescription
                            }
                            controller.dismiss(animated: true, completion: nil)
                        }
                        self.present(dropIn!, animated: true, completion: nil)
                case .failure(let error):
                    print("error: \(error?.code) \(error?.message)")
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
