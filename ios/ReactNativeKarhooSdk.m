#import "ReactNativeKarhooSdk.h"
#import <React/RCTBridgeModule.h>

@interface

RCT_EXTERN_MODULE(KarhooModule, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)identifier referer:(NSString *)referer organisationId:(NSString *)organisationId)

RCT_EXTERN_METHOD(initializePaymentForGuest:(NSString *)organisationId currency:(NSString *)currency)

@end
