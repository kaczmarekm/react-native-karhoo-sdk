const mockReactNativeKarhooSdk = {
  initialize: () => jest.fn(),
  getPaymentNonce: () => jest.fn(),
  bookTrip: () => jest.fn(),
  cancellationFee: () => jest.fn(),
  cancelTrip: () => jest.fn(),
};

module.exports = mockReactNativeKarhooSdk;
