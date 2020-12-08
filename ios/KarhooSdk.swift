import KarhooSDK
import BraintreeDropIn
import Braintree

@objc(KarhooSdk)
class KarhooSdk: NSObject {
    @objc func initialize(_ identifier: String, referer: String, organisationId: String) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId))
    }

    @objc func getPaymentNonce(_ organisationId: String, paymentData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo
            .getPaymentService()
            .initialisePaymentSDK(paymentSDKTokenPayload: PaymentSDKTokenPayload(organisationId: organisationId, currency: paymentData["currency"] as! String))
            .execute { result in
                switch result {
                    case .success(let sdk):
                        let amountString = paymentData["amount"] as! String
                        let amountDecimal = Decimal(string: amountString)
                        
                        if (amountDecimal == nil) {
                            print("KarhooSdk ERROR: amount not formatted correctly")
                            reject("KarhooSdk ERROR", "amount not formatted correctly", nil)
                            return;
                        }
                        
                        let amountNSDecimalNumber = NSDecimalNumber(decimal: amountDecimal!)
                        
                        let threeDSecureRequest = BTThreeDSecureRequest()
                        threeDSecureRequest.amount = amountNSDecimalNumber
                        threeDSecureRequest.versionRequested = .version2
                        
                        let dropInRequest =  BTDropInRequest()
                        dropInRequest.threeDSecureVerification = true
                        dropInRequest.threeDSecureRequest = threeDSecureRequest
                        
                        let dropIn = BTDropInController(authorization: sdk.token, request: dropInRequest) {
                            (controller, result, error) in
                                if (error != nil) {
                                    if let unwrappedError = error {
                                        print("KarhooSdk ERROR: \(unwrappedError)")
                                    } else {
                                        print("KarhooSdk ERROR: BTDropInController error")
                                    }
                                    controller.dismiss(animated: true, completion: nil)
                                    reject("KarhooSdk ERROR", nil, error)
                                } else if (result?.isCancelled == true) {
                                    print("KarhooSdk CANCELLED")
                                    controller.dismiss(animated: true, completion: nil)
                                    reject("KarhooSdk ERROR", "CANCELLED", nil)
                                } else if let result = result {
                                    print("KarhooSdk SUCCESS")
                                    let nonce = result.paymentMethod?.nonce
                                    let resultDict: NSDictionary = [
                                        "nonce": nonce!,
                                    ]
                                    controller.dismiss(animated: true, completion: nil)
                                    resolve(resultDict)
                                }
                        }
                        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
                        rootViewController?.present(dropIn!, animated: true, completion: nil)
                    case .failure(let error):
                        if let unwrappedError = error {
                            print("KarhooSdk ERROR: \(unwrappedError.code) \(unwrappedError.message)")
                        } else {
                            print("KarhooSdk ERROR: Karhoo.getPaymentService().initialisePaymentSDK() error")
                        }
                        reject("KarhooSdk ERROR", nil, error)
                }
            }
    }

    @objc func bookTrip(_ passenger: NSDictionary, quoteId: String, paymentNonce: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let passengers = Passengers(
            additionalPassengers: 0,
            passengerDetails: [
                PassengerDetails(
                    firstName: passenger["firstName"] as! String,
                    lastName: passenger["lastName"] as! String,
                    email: passenger["email"] as! String,
                    phoneNumber: passenger["mobileNumber"] as! String,
                    locale: passenger["locale"] as! String
                )
            ]
        )
        let tripBooking = TripBooking(
            quoteId: quoteId,
            passengers: passengers,
            flightNumber: nil,
            paymentNonce: paymentNonce,
            comments: nil
        )
        Karhoo
            .getTripService()
            .book(tripBooking: tripBooking)
            .execute { result in
                switch result {
                    case .success(let trip):
                        print("KarhooSdk SUCCESS: \(trip)")
                        let resultDict: NSDictionary = [
                            "tripId": trip.tripId,
                            "followCode": trip.followCode
                        ]
                        resolve(resultDict)
                    case .failure(let error):
                        if let unwrappedError = error {
                            print("KarhooSdk ERROR: \(unwrappedError.code) \(unwrappedError.message)")
                        } else {
                            print("KarhooSdk ERROR: Karhoo.getTripService().book() error")
                        }
                        reject("KarhooSdk ERROR", nil, error)
                }
            }
    }

    @objc func cancelTrip(_ tripId: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let tripCancellation = TripCancellation(tripId: tripId as String, cancelReason: .notNeededAnymore)
        Karhoo
            .getTripService()
            .cancel(tripCancellation: tripCancellation)
            .execute { result in
                switch result {
                    case .success:
                        print("KarhooSdk SUCCESS: trip cancelled")
                        let resultDict: NSDictionary = [
                            "tripCancelled": true,
                        ]
                        resolve(resultDict)
                    case .failure(let error):
                        if let unwrappedError = error {
                            print("KarhooSdk ERROR: \(unwrappedError.code) \(unwrappedError.message)")
                        } else {
                            print("KarhooSdk ERROR: Karhoo.getTripService().cancel() error")
                        }
                        reject("KarhooSdk ERROR", nil, error)
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
