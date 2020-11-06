# react-native-react-native-karhoo-sdk

## Getting started

`$ npm install react-native-react-native-karhoo-sdk --save`

### Installation

* update Podfile
** add
`use_modular_headers!`

** update 
`
    pod 'glog', :podspec => '../node_modules/react-native/third-party-podspecs/glog.podspec', :modular_headers => false
    pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec', :modular_headers => false
`

* add to project level `build.gradle`:
`maven { url 'https://flit-tech.bintray.com/Android' }`

* link
`$ react-native link react-native-react-native-karhoo-sdk`

## Usage

###### import
```javascript
import ReactNativeKarhooSdk from 'react-native-react-native-karhoo-sdk';
```
###### initialize
```javascript
ReactNativeKarhooSdk.initialize(
    identifier: String,
    referer: String,
    organisationId: String
);
```