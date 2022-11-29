import { NativeModules } from "react-native";

const { KarhooSdk: KarhooSdkNative } = NativeModules;

const initialize = {
  initialize: (identifier, referer, organisationId, isProduction) =>
    KarhooSdkNative.initialize(
      identifier,
      referer,
      organisationId,
      isProduction
    ),
};

const userService = {
  register: (registrationData) => KarhooSdkNative.register(registrationData),
  login: (loginData) => KarhooSdkNative.login(loginData),
  logout: () => KarhooSdkNative.logout(),
  currentUser: () => KarhooSdkNative.currentUser(),
};

const authService = {
  loginWithToken: (token) => KarhooSdkNative.loginWithToken(token),
};

const addressService = {
  placeSearch: (placeSearchData) => KarhooSdkNative.placeSarch(placeSearchData),
  locationInfo: (locationInfoData) =>
    KarhooSdkNative.locationInfo(locationInfoData),
};

const paymentService = {
  getPaymentNonce: (organisationId, paymentData) =>
    KarhooSdkNative.getPaymentNonce(organisationId, paymentData),
};

const tripService = {
  bookTrip: (bookTripData) => KarhooSdkNative.bookTrip(bookTripData),
  cancellationFee: (followCode) => KarhooSdkNative.cancellationFee(followCode),
  cancelTrip: (followCode) => KarhooSdkNative.cancelTrip(followCode),
};

const KarhooSdk = {
  ...initialize,
  ...userService,
  ...authService,
  ...addressService,
  ...paymentService,
  ...tripService,
};

export default KarhooSdk;
