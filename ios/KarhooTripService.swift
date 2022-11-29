import KarhooSDK
import BraintreeDropIn

class KarhooTripService {
    static let BOOKING_FAILED = "BOOKING_FAILED";
    static let TRIP_CANCEL_FAILED = "TRIP_CANCEL_FAILED";
    static let CANCELLATION_FEE_FAILED = "CANCELLATION_FEE_RETRIEVE_FAILED";

    static func bookTrip(_ bookTripData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let passengerDict = bookTripData["passenger"] as! NSDictionary;
        let passengers = Passengers(
            additionalPassengers: 0,
            passengerDetails: [
                PassengerDetails(
                    firstName: passengerDict["firstName"] as! String,
                    lastName: passengerDict["lastName"] as! String,
                    email: passengerDict["email"] as! String,
                    phoneNumber: passengerDict["mobileNumber"] as! String,
                    locale: passengerDict["locale"] as! String
                )
            ]
        )
        let tripBooking = TripBooking(
            quoteId: bookTripData["quoteId"] as! String,
            passengers: passengers,
            flightNumber: nil,
            paymentNonce: bookTripData["paymentNonce"] as? String,
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
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooTripService.BOOKING_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func cancellationFee(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
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
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooTripService.CANCELLATION_FEE_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func cancelTrip(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
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
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooTripService.TRIP_CANCEL_FAILED, nil, errorDict as? Error)
                }
            }
    }
}
