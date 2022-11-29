import KarhooSDK

class KarhooAddressService {
    static let PLACE_SEACH_FAILED = "PLACE_SEACH_FAILED";
    static let LOCATION_INFO_FAILED = "LOCATION_INFO_FAILED";

    static func placeSearch(_ placeSearchData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
       let position = Position(
            latitude: placeSearchData["latitude"] as! Double,
            longitude: placeSearchData["longitude"] as! Double
        );
        let placeSearch = PlaceSearch(
            position: position,
            query: placeSearchData["query"] as! String,
            sessionToken: placeSearchData["token"] as! String
        );
        Karhoo
            .getAddressService()
            .placeSearch(placeSearch: placeSearch)
            .execute { result in
                switch result {
                    case .success(let places, let correlationId):
                        let resultDict: NSDictionary = [
                            "places": places,
                            "correlationId": correlationId!
                        ]
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooAddressService.PLACE_SEACH_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func locationInfo(_ locationInfoData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let locationInfoSearch = LocationInfoSearch(
            placeId: locationInfoData["placeId"] as! String,
            sessionToken: locationInfoData["token"] as! String
        )
        Karhoo
            .getAddressService()
            .locationInfo(locationInfoSearch: locationInfoSearch)
            .execute { result in
                switch result {
                    case .success(let locationInfo, let correlationId):
                        let resultDict: NSDictionary = [
                            "locationInfo": locationInfo,
                            "correlationId": correlationId!
                        ]
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooAddressService.LOCATION_INFO_FAILED, nil, errorDict as? Error)
                }
            }
    }
}

