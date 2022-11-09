declare namespace KarhooSdk {
  interface CorrelationId {
    correlationId: string;
  }

  interface PaymentNonce extends CorrelationId {
    nonce: string;
  }

  interface TripInfo extends CorrelationId {
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

  interface TripCancelledInfo extends CorrelationId {
    tripCancelled: true;
  }

  interface PaymentData {
    currency: string;
    amount: string;
  }

  interface Passenger {
    firstName: string;
    lastName: string;
    email: string;
    mobileNumber: string;
    locale: string;
  }

  const initialize: (
    identifier: string,
    referer: string,
    organisationId: string,
    isProduction: boolean
  ) => void;
  const getPaymentNonce: (
    organisationId: string,
    paymentData: PaymentData
  ) => Promise<PaymentNonce>;
  const bookTrip: (
    passenger: Passenger,
    quoteId: string,
    paymentNonce: string
  ) => Promise<TripInfo>;
  const cancellationFee: (followCode: string) => Promise<CancellationFeeInfo>;
  const cancelTrip: (followCode: string) => Promise<TripCancelledInfo>;
}

export = KarhooSdk;
