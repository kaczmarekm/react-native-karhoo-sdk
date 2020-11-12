import KarhooSDK
import BraintreeDropIn
import Braintree

@objc(KarhooSdk)
class KarhooSdk: NSObject {
    @objc(initialize:referer:organisationId:)
    func initialize(identifier: String, referer: String, organisationId: String) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId))
    }

    @objc(getPaymentNonce:currency:resolver:rejecter:)
    func getPaymentNonce(organisationId: String, currency: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo.getPaymentService().initialisePaymentSDK(paymentSDKTokenPayload: PaymentSDKTokenPayload(organisationId: organisationId, currency: currency))
            .execute { result in
                switch result {
                    case .success(let sdk):
                        let request =  BTDropInRequest()
                        let dropIn = BTDropInController(authorization: sdk.token, request: request) {
                            (controller, result, error) in
                                if (error != nil) {
                                    print("KarhooSdk ERROR \(error.code) \(error.message)")
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
                        reject(nil, nil, nil)
                }
            }
    }

    @objc(bookTrip:quoteId:paymentNonce:)
    func bookTrip(userInfo: NSDictionary, quoteId: String, paymentNonce: String, resolver resolve: @escaping RCTPromiseRejectBlock, rejecter reject: @escaping RCTPromiseResolveBlock) -> Void {
        let tripService = Karhoo.getTripService()
        let passengerDetails = PassengerDetails(
            firstName: userInfo["firstName"],
            lastName: userInfo["lastName"],
            email: userInfo["email"],
            mobileNumber: userInfo["mobileNumber"],
            locale: ["locale"]
        )
        let passengers = Passengers(additionalPassengers: 0, passengerDetails: [passengerDetails])
        let tripBooking = TripBooking(
            quoteId: quoteId,
            passengers: passengers,
            flightNumber: nil,
            paymentNonce: paymentNonce,
            comments: nil
        )
        tripService.book(tripBooking: tripBooking).execute { result in
            switch result {
                case .success(let trip):
                    print("KarhooSdk SUCCESS: \(trip)")
                    var resultDict: NSDictionary = [   
                        "tripId": trip,                                                                     
                    ]
                    resolve(resultDict)
                case .failure(let error):
                    print("KarhooSdk ERROR: \(error.code) \(error.message)")
                    reject(nil, nil, nil)
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
