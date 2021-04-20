import { NativeModules } from 'react-native';

const { KarhooSdk } = NativeModules;

export default {
    initialize: (identifier, referer, organisationId, isProduction) => KarhooSdk.initialize(identifier, referer, organisationId, isProduction),
    getPaymentNonce: (organisationId, paymentData) => KarhooSdk.getPaymentNonce(organisationId, paymentData),
    bookTrip: (passenger, quoteId, paymentNonce) => KarhooSdk.bookTrip(passenger, quoteId, paymentNonce),
    cancellationFee: (tripId) => KarhooSdk.cancellationFee(tripId),
    cancelTrip: (followCode) => KarhooSdk.cancelTrip(followCode)
};