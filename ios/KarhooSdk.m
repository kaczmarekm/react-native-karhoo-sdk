#import <React/RCTBridge.h>

@interface RCT_EXTERN_MODULE(KarhooSdk, NSObject)
    // Initialize
    //
    RCT_EXTERN_METHOD(initialize:(NSString *)identifier referer:(NSString *)referer organisationId:(NSString *)organisationId isProduction:(BOOL)isProduction)
    
    // KarhooUserService
    //
    RCT_EXTERN_METHOD(register:(NSDictionary *)registrationData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
    RCT_EXTERN_METHOD(login:(NSDictionary *)loginData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
    RCT_EXTERN_METHOD(logout)
    RCT_EXTERN_METHOD(currentUser)

    // KarhooAuthService
    //
    RCT_EXTERN_METHOD(loginWithToken:(NSString *)token resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)

    // KarhooAddressService
    //
    RCT_EXTERN_METHOD(placeSearch:(NSDictionary *)placeSearchData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
    RCT_EXTERN_METHOD(locationInfo:(NSDictionary *)locationInfoData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)

    // KarhooQuotesService
    //

    // KarhooPaymentService
    //
    RCT_EXTERN_METHOD(getPaymentNonce:(NSDictionary *)paymentData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)

    // KarhooTripService    
    //
    RCT_EXTERN_METHOD(bookTrip:(NSDictionary *)bookTripData resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
    RCT_EXTERN_METHOD(cancellationFee:(NSString *)followCode resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
    RCT_EXTERN_METHOD(cancelTrip:(NSString *)followCode resolve:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject)
@end
