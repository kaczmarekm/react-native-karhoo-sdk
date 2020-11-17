#import <React/RCTBridge.h>

@interface RCT_EXTERN_MODULE(KarhooSdk, NSObject)
    RCT_EXTERN_METHOD(initialize:(NSString *)identifier referer:(NSString *)referer organisationId:(NSString *)organisationId)
    RCT_EXTERN_METHOD(getPaymentNonce:(NSString *)organisationId paymentData:(NSDictionary *)paymentData)
    RCT_EXTERN_METHOD(bookTrip:(NSDictionary *)passenger quoteId:(NSString *)quoteId paymentNonce:(NSString *)paymentNonce)
@end

