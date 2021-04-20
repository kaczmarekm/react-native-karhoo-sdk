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
    url "https://cardinalcommerce.bintray.com/android"
    credentials {
        username 'braintree-team-sdk@cardinalcommerce'
        password '220cc9476025679c4e5c843666c27d97cfb0f951'
    }
}
```

#### 2.3. Update app level `build.gradle`:
```
implementation 'com.braintreepayments.api:drop-in:4.4.0'
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

#### 2.5. Link
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
* this step is not required, but user should be acquainted with cancellation fee amount before he cancel ride
```javascript
KarhooSdk.cancellationFee(tripId): Promise<CancellationFeeInfo>;
```
#### 3.6 ...before you cancel trip
```javascript
KarhooSdk.cancelTrip(tripId): Promise<TripCancelledInfo>;
```