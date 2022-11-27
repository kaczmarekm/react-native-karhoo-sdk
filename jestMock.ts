import { PaymentNonce } from ".";

const ReactNativeKarhooSdkTestValues = {
  TEST_CORRELATION_ID: "TEST_CORRELATION_ID",
  TEST_PAYMENT_NONCE: "TEST_PAYMENT_NONCE",
  TEST_TRIP_ID: "TEST_TRIP_ID",
  TEST_CANCELLATION_FEE_BOOLEAN: true,
  TEST_CANCELLATION_FEE_CURRENCY: "TEST_CANCELLATION_FEE_CURRENCY",
  TEST_CANCELLATION_FEE_TYPE: "TEST_CANCELLATION_FEE_TYPE",
  TEST_CANCELLATION_FEE_VALUE: 1,
  TEST_TRIP_CANCELLED_BOOLEAN: true,
};

const mockReactNativeKarhooSdk = {
  initialize: jest.fn(),
  getPaymentNonce: jest.fn(
    (): PaymentNonce => ({
      nonce: ReactNativeKarhooSdkTestValues.TEST_PAYMENT_NONCE,
      correlationId: ReactNativeKarhooSdkTestValues.TEST_CORRELATION_ID,
    })
  ),
  bookTrip: jest.fn(() => ({
    tripId: ReactNativeKarhooSdkTestValues.TEST_TRIP_ID,
    correlationId: ReactNativeKarhooSdkTestValues.TEST_CORRELATION_ID,
  })),
  cancellationFee: jest.fn(() => ({
    cancellationFee:
      ReactNativeKarhooSdkTestValues.TEST_CANCELLATION_FEE_BOOLEAN,
    fee: {
      currency: ReactNativeKarhooSdkTestValues.TEST_CANCELLATION_FEE_CURRENCY,
      type: ReactNativeKarhooSdkTestValues.TEST_CANCELLATION_FEE_TYPE,
      value: ReactNativeKarhooSdkTestValues.TEST_CANCELLATION_FEE_VALUE,
    },
    correlationId: ReactNativeKarhooSdkTestValues.TEST_CORRELATION_ID,
  })),
  cancelTrip: jest.fn(() => ({
    tripCancelled: ReactNativeKarhooSdkTestValues.TEST_TRIP_CANCELLED_BOOLEAN,
    correlationId: ReactNativeKarhooSdkTestValues.TEST_CORRELATION_ID,
  })),
};

export default mockReactNativeKarhooSdk;
export { ReactNativeKarhooSdkTestValues };
