# react-native-karhoo-sdk v1.2.0

- [Description](#description)
- [Installation](#started)
- [Setup](#setup)
  - [Follow Braintree docs](#follow-braintree-docs)
    - [Android](#android)
    - [iOS](#iOS)
- [Usage](#usage)
  - [Import](#import)
  - [Initialize SKD](#initialize-sdk)
  - [Obtain payment nonce](#obtain-payment-nonce)
  - [Book a ride](#book-a-ride)
  - [Get cancellation fee](#get-cancellation-fee)
  - [Cancel a trip](#cancel-a-trip)
  - [Using Jest mock](#using-jest-mock)
- [Running example project](#running-example-project)

# Description

This is a simple wrapper to some of functionalities offered by [Network SDK](https://developer.karhoo.com/docs/introduction-to-network-sdk) created by [Karhoo](https://www.karhoo.com/).
Using this react-native wrapper you can:

- obtain payment nonce
- book a ride
- obtain cancellation fee info
- cancel a ride

# Getting started

`$ yarn add @iteratorsmobile/react-native-karhoo-sdk` or
`$ npm install @iteratorsmobile/react-native-karhoo-sdk --save`

# Setup

### Follow Braintree docs

#### Android

##### Update project level `build.gradle`:

```
repositories {
    maven {
        url "https://cardinalcommerceprod.jfrog.io/artifactory/android"
        credentials {
            username 'braintree_team_sdk'
            password 'AKCp8jQcoDy2hxSWhDAUQKXLDPDx6NYRkqrgFLRc3qDrayg6rrCbJpsKKyMwaykVL8FWusJpp'
        }
    }
}
```

##### Update app level `build.gradle`:

```
implementation 'com.braintreepayments.api:drop-in:6.4.0'
```

##### Update `AndroidManifest`

```
<activity android:name="com.braintreepayments.api.BraintreeBrowserSwitchActivity"
    android:launchMode="singleTask">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="${applicationId}.braintree" />
    </intent-filter>
</activity>
```

#### iOS

##### Update `Podfile`

```
pod 'Braintree'
pod 'BraintreeDropIn', :modular_headers => true
```

##### Update `AppDelegate.mm`

```
// imports
#import "BraintreeCore.h"
```

Add function to handle payment URL scheme:

```
- (NSString *)paymentsURLScheme {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [NSString stringWithFormat:@"%@.%@", bundleIdentifier, @"payments"];
}
```

Add before `return YES;` line:

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // ...
    [BTAppContextSwitcher setReturnURLScheme:self.paymentsURLScheme];
    return YES;
}
```

Add openURL handler or edit existing one:

```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL handled = NO;

    if ([url.scheme localizedCaseInsensitiveCompare:([NSString stringWithFormat:@"%@%@", self.paymentsURLScheme)] == NSOrderedSame) {
        handled = [BTAppContextSwitcher handleOpenURL:url];
    }

    return handled;
}
```

NOTE:
If you are using RCTLinkingManager it has to be placed in last if statement, eg:

```
if ([url.scheme localizedCaseInsensitiveCompare:([NSString stringWithFormat:@"%@%@", self.paymentsURLScheme)] == NSOrderedSame) {
    handled = [BTAppContextSwitcher handleOpenURL:url];
} else if ([RCTLinkingManager application:app openURL:url options:options]) {
    handled = YES;
}
```

##### Register payment URL type:

3.1 For each target in your app, in XCode go to App Target > Info > URL Types
3.2 Click '+', add URL `${bundleId}.payments`, where `${bundleId}` is your app bundle id

##### Add required permissions:

- `NSLocationWhenInUseUsageDescription`

# Usage

#### Import

```javascript
import KarhooSdk from "@iteratorsmobile/react-native-karhoo-sdk";
```

Note:
You can also import [predefined types]("./index.d.ts").

#### Initialize sdk

This step is required before using any other function from this library.

```javascript
KarhooSdk.initialize(identifier, referer, organisationId, isProduction);
```

#### Obtain payment nonce

```javascript
const paymentNonce: PaymentNonce = await KarhooSdk.getPaymentNonce(
  organisationId,
  {
    currency,
    amount,
  }
);
```

#### Book a ride

```javascript
const tripInfo: TripInfo = await KarhooSdk.bookTrip(
  {
    firstName,
    lastName,
    email,
    mobileNumber,
    locale,
  },
  quoteId,
  paymentNonce
);
```

#### Get cancellation fee

This step is not required, but user should be acquainted with cancellation fee amount before he cancels a ride.

```javascript
const cancellationFeeInfo: CancellationFeeInfo =
  await KarhooSdk.cancellationFee(followCode);
```

#### Cancel a trip

```javascript
const cancelledTripInfo: CancelledTripInfo = KarhooSdk.cancelTrip(followCode);
```

#### Using Jest mock

Add following mock to your Jest setup files:

```javascript
import { mockReactNativeKarhooSdk } from "@iteratorsmobile/react-native-karhoo-sdk/jestMock";

jest.mock(
  "@iteratorsmobile/react-native-karhoo-sdk",
  () => mockReactNativeKarhooSdk
);
```

# Running example project

#### Install dependencies

`$ yarn && cd example && yarn && cd ios && pod install && cd .. && clear`

#### Setup

Create `.env` file under `<libraryRootDir>/example/` directory. Paste this:

```
KARHOO_ORGANISATION_ID=
KARHOO_REFERER_ID=
KARHOO_IDENTIFIER=
```

And then add values obtained from Karhoo team.

#### Run

Start 'example' project just as a normal react-native project:
`$ yarn android` or
`$ yarn ios`
