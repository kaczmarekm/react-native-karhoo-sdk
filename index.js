import { NativeModules } from "react-native";

const { KarhooSdk: KarhooSdkNative } = NativeModules;

const KarhooSdk = {
  initialize: (identifier, referer, organisationId, isProduction) =>
    KarhooSdkNative.initialize(
      identifier,
      referer,
      organisationId,
      isProduction
    ),
  getPaymentNonce: (organisationId, paymentData) =>
    KarhooSdkNative.getPaymentNonce(organisationId, paymentData),
  bookTrip: (passenger, quoteId, paymentNonce) =>
    KarhooSdkNative.bookTrip(passenger, quoteId, paymentNonce),
  cancellationFee: (followCode) => KarhooSdkNative.cancellationFee(followCode),
  cancelTrip: (followCode) => KarhooSdkNative.cancelTrip(followCode),
};

export default KarhooSdk;
