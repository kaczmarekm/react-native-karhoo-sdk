import KarhooSDK
import BraintreeDropIn

@objc(KarhooSdk)
class KarhooSdk: NSObject {
    @objc func initialize(_ identifier: String, referer: String, organisationId: String, isProduction: Bool) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId, isProduction: isProduction))
    }

    @objc func getPaymentNonce(_ organisationId: String, paymentData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
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
                                "correlationId": correlationId!
                            ]
                            print("KarhooSdk ERROR: amount not formatted correctly \(errorDict)")
                            reject("KarhooSdk ERROR", "amount not formatted correctly", errorDict as? Error)
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
                                let errorDict: NSDictionary = [
                                    "error": error!,
                                    "correlationId": correlationId!
                                ]
                                if (error != nil) {
                                    controller.dismiss(animated: true, completion: nil)
                                    print("KarhooSdk ERROR getPaymentNonce FAILURE: \(errorDict)")
                                    reject("KarhooSdk ERROR", "getPaymentNonce", errorDict as? Error)
                                } else if (result?.isCanceled == true) {
                                    controller.dismiss(animated: true, completion: nil)
                                    print("KarhooSdk ERROR getPaymentNonce CANCELLED: \(errorDict)")
                                    reject("KarhooSdk ERROR", "getPaymentNonce CANCELLED", errorDict as? Error)
                                } else if let result = result {
                                    let nonce = result.paymentMethod?.nonce
                                    let resultDict: NSDictionary = [
                                        "nonce": nonce!,
                                        "correlationId": correlationId!
                                    ]
                                    controller.dismiss(animated: true, completion: nil)
                                    print("KarhooSdk getPaymentNonce SUCCESS")
                                    resolve(resultDict)
                                }
                        }
                        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
                        rootViewController?.present(dropIn!, animated: true, completion: nil)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!,
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk ERROR getPaymentNonce FAILURE: \(errorDict)")
                        reject("KarhooSdk ERROR", "getPaymentNonce", errorDict as? Error)
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
                    case .success(let trip, let correlationId):
                        let resultDict: NSDictionary = [
                            "tripId": trip.tripId,
                            "followCode": trip.followCode,
                            "correlationId": correlationId!,
                        ]
                        print("KarhooSdk SUCCESS: \(resultDict)")
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!,
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk ERROR bookTrip FAILURE: \(errorDict)")
                        reject("KarhooSdk ERROR", "bookTrip", errorDict as? Error)
                }
            }
    }

    @objc func cancellationFee(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo
            .getTripService()
            .cancellationFee(identifier: followCode as String)
            .execute { result in
                switch result {
                    case .success(let bookingFee, let correlationId):
                        let resultDict: NSDictionary = [
                            "cancellationFee": bookingFee.cancellationFee,
                            "fee":  [
                                "currency": bookingFee.fee.currency,
                                "type": bookingFee.fee.value,
                                "value": bookingFee.fee.value,
                            ],
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk SUCCESS: \(bookingFee)")
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!,
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk ERROR cancellationFee FAILURE: \(errorDict)")
                        reject("KarhooSdk ERROR", "cancellationFee", errorDict as? Error)
                }
            }
    }

    @objc func cancelTrip(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let tripCancellation = TripCancellation(tripId: followCode as String, cancelReason: .notNeededAnymore)
        Karhoo
            .getTripService()
            .cancel(tripCancellation: tripCancellation)
            .execute { result in
                switch result {
                    case .success(_, let correlationId):
                        let resultDict: NSDictionary = [
                            "tripCancelled": true,
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk SUCCESS: trip cancelled: \(resultDict)")
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!,
                            "correlationId": correlationId!
                        ]
                        print("KarhooSdk ERROR cancelTrip FAILURE: \(errorDict)")
                        reject("KarhooSdk ERROR", "cancelTrip", errorDict as? Error)
                }
            }
    }
}

struct KarhooConfiguration: KarhooSDKConfiguration {
    var identifier: String
    var referer: String
    var organisationId: String
    var isProduction: Bool

    init (identifier: String, referer: String, organisationId: String, isProduction: Bool) {
        self.identifier = identifier
        self.referer = referer
        self.organisationId = organisationId
        self.isProduction = isProduction
    }

    func environment() -> KarhooEnvironment {
        return self.isProduction ? .production : .sandbox
    }

    func authenticationMethod() -> AuthenticationMethod {
        return .guest(settings: GuestSettings(identifier: self.identifier, referer: self.referer, organisationId: self.organisationId))
    }
}
