#import "ReactNativeKarhooSdk.h"
#import <React/RCTBridgeModule.h>


@interface RCT_EXTERN_MODULE(CalendarManager, NSObject)

RCT_EXPORT_MODULE()

RCT_EXTERN_METHOD(initialize:(NSString *)identifier referer:(NSString *)referer organisationId:(NSString *)organisationId)

@end
