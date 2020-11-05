import { NativeModules } from 'react-native';

const { ReactNativeKarhooSdk } = NativeModules;

export default {
    initialize: (identifier, referer, organisationId) => {
        return ReactNativeKarhooSdk.initialize(identifier, referer, organisationId)
    }
};
