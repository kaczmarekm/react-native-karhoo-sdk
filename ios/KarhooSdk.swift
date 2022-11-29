import KarhooSDK
import BraintreeDropIn

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

@objc(KarhooSdk)
class KarhooSdk: NSObject { 
    @objc func initialize(_ identifier: String, referer: String, organisationId: String, isProduction: Bool) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId, isProduction: isProduction))
    }

    // KarhooUserService
    //

    @objc func register(_ registrationData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooUserService.register(registrationData, resolve: resolve, reject: reject);
    }

    @objc func login(_ loginData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooUserService.login(loginData, resolve: resolve, reject: reject);
    }

    @objc func logout(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooUserService.logout(resolve, reject: reject);
    }

    @objc func currentUser(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooUserService.currentUser(resolve, reject: reject);
    }

    // KarhooAuthService
    //

    @objc func loginWithToken(_ token: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooAuthService.loginWithToken(token, resolve: resolve, reject: reject);
    }

    // KarhooAddressService
    //

    @objc func placeSearch(_ placeSearchData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooAddressService.placeSearch(placeSearchData, resolve: resolve, reject: reject);
    }

    @objc func locationInfo(_ locationInfoData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooAddressService.locationInfo(locationInfoData, resolve: resolve, reject: reject);
    }

    // KarhooPaymentService
    // 

    @objc func getPaymentNonce(_ organisationId: String, paymentData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {        
        return KarhooPaymentService.getPaymentNonce(organisationId, paymentData: paymentData, resolve: resolve, reject: reject);
    }

    // KarhooTripService
    //
    
    @objc func bookTrip(_ bookTripData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
       return KarhooTripService.bookTrip(bookTripData, resolve: resolve, reject: reject);
    }

    @objc func cancellationFee(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooTripService.cancellationFee(followCode, resolve: resolve, reject: reject);
    }

    @objc func cancelTrip(_ followCode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        return KarhooTripService.cancelTrip(followCode, resolve: resolve, reject: reject);
    }
}


