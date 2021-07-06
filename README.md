# react-native-karhoo-sdk

## 1. Getting started

`$ npm install @iteratorsmobile/react-native--karhoo-sdk --save`

or 

`$ yarn add @iteratorsmobile/react-native-karhoo-sdk`

## 2. Installation

#### 2.1. Update Podfile
add 
```
use_modular_headers!
```
update
```
pod 'glog', :podspec => '../node_modules/react-native/third-party-podspecs/glog.podspec', :modular_headers => false
pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec', :modular_headers => false
````

#### 2.2. Update project level `build.gradle`:
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

#### 2.3. Update app level `build.gradle`:
```
implementation 'com.braintreepayments.api:drop-in:5.+'
```

#### 2.4. Update `AndroidManifest`
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

#### 2.5 Follow Braintree docs

1. Add to Podfile
```
    pod 'Braintree'
```

2. Update AppDelegate.m
```
    // imports
    @import Braintree;
```
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
    
    // other code
    
    [BTAppSwitch setReturnURLScheme:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundleIdentifier], @".payments"]];
    
    return YES;
}
```
```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  BOOL handled = NO;
  
  if ([url.scheme localizedCaseInsensitiveCompare:([NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundleIdentifier], @".payments"])] == NSOrderedSame) {
    handled = [BTAppSwitch handleOpenURL:url options:options];
  }
  
  /* 
    NOTE: if you are using RCTLinkingManager it has to be placed in last 'if', for example :
    
    else if ([RCTLinkingManager application:app openURL:url options:options]) {
    handled = YES;
  }
*/
  return handled;
}
```

3. Register URL Type:
3.1 For each target in your app, in XCode go to App Target > Info > URL Types
3.2 Click '+', add URL `${bundleId}.payments`, where `${bundleId}` is your app bundle id

4. Add required permission:
* `NSLocationWhenInUseUsageDescription`

#### 2.6. Link
```
$ react-native link @iteratorsmobile/react-native-karhoo-sdk
```

## 3. Usage
#### 3.1 Import
```javascript
import KarhooSdk from '@iteratorsmobile/react-native-karhoo-sdk';
```
#### 3.2 Before using other features you have to initialize sdk:
```javascript
KarhooSdk.initialize(
    identifie,
    referer,
    organisationId,
    isProduction,
): void;
```
#### 3.3 Obtain payment nonce..
```javascript
KarhooSdk.getPaymentNonce(
    organisationId,
    paymentData: {
        currency,
        amount,
    },
): Promise<PaymentNonce>;
```
#### 3.4 ...and pass along with other booking data t book a ride
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
#### 3.5 Get cancellation fee data... 
* this step is not required, but user should be acquainted with cancellation fee amount before he cancels ride
```javascript
KarhooSdk.cancellationFee(followCode): Promise<CancellationFeeInfo>;
```
#### 3.6 ...before you cancel trip
```javascript
KarhooSdk.cancelTrip(followCode): Promise<TripCancelledInfo>;
```
