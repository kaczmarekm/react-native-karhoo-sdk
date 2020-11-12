import { NativeModules } from 'react-native';

const { KarhooSdk } = NativeModules;

export default {
    initialize: (identifier, referer, organisationId) => {
        return KarhooSdk.initialize(identifier, referer, organisationId)
    },
    getPaymentNonce: (organisationId, currency) => {
        return KarhooSdk.getPaymentNonce(organisationId, currency)
    },
    bookTrip: (userInfo, quoteId, paymentNonce) => {
        return KarhooSdk.bookTrip(userInfo, quoteId);
    }
};
