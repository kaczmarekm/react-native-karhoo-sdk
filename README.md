# react-native-react-native-karhoo-sdk

## Getting started

`$ npm install react-native-react-native-karhoo-sdk --save`

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

* link
`$ react-native link react-native-react-native-karhoo-sdk`

## Usage

```javascript
import KarhooSdk from 'react-native-react-native-karhoo-sdk';
```
```javascript
KarhooSdk.initialize(
    identifier: String,
    referer: String,
    organisationId: String
);
```
```javascript
KarhooSdk.getPaymentNonce(
    organisationId: String,
    currency: String
);
```