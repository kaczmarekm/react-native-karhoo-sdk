import KarhooSDK
import BraintreeDropIn

@objc(KarhooSdk)
class KarhooSdk: NSObject {
    static let PAYMENT_NONCE_CANCELLED = "PAYMENT_NONCE_CANCELLED";
    static let PAYMENT_NONCE_FAILED = "PAYMENT_NONCE_FAILED";
    static let BOOKING_FAILED = "BOOKING_FAILED";
    static let TRIP_CANCEL_FAILED = "TRIP_CANCEL_FAILED";
    static let CANCELLATION_FEE_FAILED = "CANCELLATION_FEE_RETRIEVE_FAILED";
    
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
                                "error": "PaymentData.amount not formatted correclty",
                                "correlationId": correlationId!
                            ]
                            reject(KarhooSdk.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
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
                                    reject(KarhooSdk.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
                                    controller.dismiss(animated: true, completion: nil)
                                } else if (result?.isCanceled == true) {
                                    let errorDict: NSDictionary = [
                                        "error": "Cancelled by user",
                                        "correlationId": correlationId!
                                    ]
                                    reject(KarhooSdk.PAYMENT_NONCE_CANCELLED, nil, errorDict as? Error)
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
                            "error": error.debugDescription,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooSdk.PAYMENT_NONCE_FAILED, nil, errorDict as? Error)
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
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error.debugDescription,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooSdk.BOOKING_FAILED, nil, errorDict as? Error)
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
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error.debugDescription,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooSdk.CANCELLATION_FEE_FAILED, nil, errorDict as? Error)
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
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error.debugDescription,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooSdk.TRIP_CANCEL_FAILED, nil, errorDict as? Error)
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
