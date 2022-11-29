declare namespace KarhooSdk {
  interface CorrelationId {
    correlationId: string;
  }

  // Config
  //
  const initialize: (
    identifier: string,
    referer: string,
    organisationId: string,
    isProduction: boolean
  ) => void;

  // User
  //
  interface UserRegistration {
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string;
    locale: string;
    password: string;
  }

  interface UserInfo {
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string;
    userId: string;
    locale: string;
  }

  interface UserLogin {
    email: string;
    password: string;
  }

  const register: (registrationData: UserRegistration) => Promise<UserInfo>;
  const login: (loginData: UserLogin) => Promise<UserInfo>;
  const logout: (loginData: UserLogin) => Promise<undefined>;
  const currentUser: (loginData: UserLogin) => Promise<UserInfo>;

  // Auth
  //
  const loginWithToken: (token: string) => Promise<UserInfo>;

  // Address
  //
  interface PlaceSearchData {
    latitude: number;
    longitude: number;
    query: string;
    token: string;
  }

  interface PlaceInfo {
    placeId: string;
    displayAddress: string;
    type: string;
  }

  interface LocationInfo {
    placeId: string;
    displayAddress: string;
    type: string;
  }

  interface LocationInfoRequest {
    placeId: string;
    token: string;
  }

  const placeSearch: (
    placeSearchData: PlaceSearchData
  ) => Promise<Array<PlaceInfo>>;
  const locationInfo: (
    locationInfoData: LocationInfoRequest
  ) => Promise<LocationInfo>;

  // Payment
  //
  interface PaymentData {
    currency: string;
    amount: string;
    organisationId: string;
  }

  interface PaymentNonce extends CorrelationId {
    nonce: string;
  }

  const getPaymentNonce: (paymentData: PaymentData) => Promise<PaymentNonce>;

  // Trip
  //
  interface Passenger {
    firstName: string;
    lastName: string;
    email: string;
    mobileNumber: string;
    locale: string;
  }

  interface TripBooking {
    passenger: Passenger;
    quoteId: string;
    paymentNonce: string;
  }

  interface Trip extends CorrelationId {
    tripId: string;
    followCode: string;
  }

  interface CancellationFeeInfo extends CorrelationId {
    cancellationFee: boolean;
    fee?: {
      currency: string;
      type: string;
      value: number;
    };
  }

  interface CancelledTripInfo extends CorrelationId {
    tripCancelled: true;
  }

  const bookTrip: (tripBooking: TripBooking) => Promise<Trip>;
  const cancellationFee: (followCode: string) => Promise<CancellationFeeInfo>;
  const cancelTrip: (followCode: string) => Promise<CancelledTripInfo>;
}

export = KarhooSdk;
