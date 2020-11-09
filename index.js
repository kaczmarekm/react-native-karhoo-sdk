import { NativeModules } from 'react-native';

const { KarhooSdk } = NativeModules;

export default {
    initialize: (identifier, referer, organisationId) => {
        return KarhooSdk.initialize(identifier, referer, organisationId)
    },
    initializePaymentForGuest: (organisationId, currency) => {
        return KarhooSdk.initializePaymentForGuest(organisationId, currency)
    }
};
