# react-native-karhoo-sdk v1.2.0

## 1. Getting started

`$ npm install @iteratorsmobile/react-native-karhoo-sdk --save`
or
`$ yarn add @iteratorsmobile/react-native-karhoo-sdk`

## 2 Follow Braintree docs

### 2.1. Android

#### 2.1.1. Update project level `build.gradle`:

```
maven { url 'https://jitpack.io' }
maven {
    url "https://cardinalcommerceprod.jfrog.io/artifactory/android"
    credentials {
        username 'braintree_team_sdk'
        password 'AKCp8jQcoDy2hxSWhDAUQKXLDPDx6NYRkqrgFLRc3qDrayg6rrCbJpsKKyMwaykVL8FWusJpp'
    }
}
```

#### 2.1.2. Update app level `build.gradle`:

```
implementation 'com.braintreepayments.api:drop-in:5.+'
```

#### 2.1.3. Update `AndroidManifest`

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

### 2.2. iOS

#### 2.2.1. Update `Podfile`

```
pod 'Braintree'
pod 'BraintreeDropIn', :modular_headers => true
```

#### 2.2.2. Update `AppDelegate.mm`

```
// imports
#import "BraintreeCore.h"
```

```
- (NSString *)paymentsURLScheme {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [NSString stringWithFormat:@"%@.%@", bundleIdentifier, @"payments"];
}
```

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    /*
        ...other code
        add ...
    */
    [BTAppContextSwitcher setReturnURLScheme:self.paymentsURLScheme];

    return YES;
}
```

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
if you are using RCTLinkingManager it has to be placed in last if statement, eg:

```
if ([url.scheme localizedCaseInsensitiveCompare:([NSString stringWithFormat:@"%@%@", self.paymentsURLScheme)] == NSOrderedSame) {
    handled = [BTAppContextSwitcher handleOpenURL:url];
} else if ([RCTLinkingManager application:app openURL:url options:options]) {
    handled = YES;
}
```

##### 2.2.3. Register URL Type:

3.1 For each target in your app, in XCode go to App Target > Info > URL Types
3.2 Click '+', add URL `${bundleId}.payments`, where `${bundleId}` is your app bundle id

##### 2.2.4. Add required permission:

- `NSLocationWhenInUseUsageDescription`

## 3. Usage

### 3.1. Import

```javascript
import KarhooSdk from "@iteratorsmobile/react-native-karhoo-sdk";
```

### 3.2. Before using other features you have to initialize sdk:

```javascript
KarhooSdk.initialize(
    identifie,
    referer,
    organisationId,
    isProduction,
): void;
```

### 3.3. Obtain payment nonce..

```javascript
KarhooSdk.getPaymentNonce(
    organisationId,
    paymentData: {
        currency,
        amount,
    },
): Promise<PaymentNonce>;
```

### 3.4. ...and pass along with other booking data t book a ride

```javascript
KarhooSdk.bookTrip(
    {
        firstName,
        lastName,
        email,
        mobileNumber,
        locale,
    },
    quoteId,
    paymentNonce,
): Promise<TripInfo>
```

### 3.5. Get cancellation fee data...

- this step is not required, but user should be acquainted with cancellation fee amount before he cancels ride

```javascript
KarhooSdk.cancellationFee(followCode): Promise<CancellationFeeInfo>;
```

### 3.6. ...before you cancel trip

```javascript
KarhooSdk.cancelTrip(followCode): Promise<TripCancelledInfo>;
```

## 4. Running example project

### 4.1. Install dependencies

`$ yarn && cd example && yarn && cd ios && pod install && cd .. && clear`

### 4.2. Run

Start 'example' project just as a normal react-native project.
