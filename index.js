import { NativeModules } from 'react-native';
import { Passenger, PaymentNonce, TripInfo, TripCancelledInfo } from '.'

const { KarhooSdk } = NativeModules;

export default {
    initialize: (identifier, referer, organisationId, isProduction) => KarhooSdk.initialize(identifier, referer, organisationId, isProduction),
    getPaymentNonce: (organisationId, paymentData) => KarhooSdk.getPaymentNonce(organisationId, paymentData),
    bookTrip: (passenger, quoteId, paymentNonce) => KarhooSdk.bookTrip(passenger, quoteId, paymentNonce),
    cancelTrip: (tripId) => KarhooSdk.cancelTrip(tripId)
};

export {
    Passenger,
    PaymentNonce,
    TripInfo,
    TripCancelledInfo
}