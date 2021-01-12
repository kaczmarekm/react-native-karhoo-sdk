# react-native-karhoo-sdk

## Getting started

`$ npm install @iteratorsmobile/react-native--karhoo-sdk --save`

or 

`$ yarn add @iteratorsmobile/react-native-karhoo-sdk`

### Installation

* update Podfile
    * add
`use_modular_headers!`
    * update
```
    pod 'glog', :podspec => '../node_modules/react-native/third-party-podspecs/glog.podspec', :modular_headers => false
    pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec', :modular_headers => false
````

* add to project level `build.gradle`:
```
maven { url 'https://flit-tech.bintray.com/Android' }`
maven {
    url "https://cardinalcommerce.bintray.com/android"
    credentials {
        username 'braintree-team-sdk@cardinalcommerce'
        password '220cc9476025679c4e5c843666c27d97cfb0f951'
    }
}
```

* add to app level `build.gradle`:
```
implementation 'com.braintreepayments.api:drop-in:4.4.0'
```

* add to `AndroidManifest`
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

* link
`$ react-native link @iteratorsmobile/react-native-karhoo-sdk`

## Usage

```javascript
import KarhooSdk from '@iteratorsmobile/react-native-karhoo-sdk';
```
```javascript
KarhooSdk.initialize(
    identifier: String,
    referer: String,
    organisationId: String,
    isProduction: Boolean
): void;
```
```javascript
KarhooSdk.getPaymentNonce(
    organisationId: String,
    paymentData: {
        currency: String;
        amount: String;
    },
): Promise<PaymentNonce>;
```
```javascript
KarhooSdk.bookTrip(
    {
        firstName: String;
        lastName: String;
        email: String;
        mobileNumber: String;
        locale: String;
    },
    quoteId: String,
    paymentNonce: String
): Promise<TripInfo>
```
```javascript
KarhooSdk.cancelTrip(
   tripId: String
): Promise<TripCancelledInfo>;
```