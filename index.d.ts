declare namespace KarhooSdk {
    interface PaymentNonce {
        nonce: string;
    }

    interface TripInfo {
        tripId: string;
        followCode: string;
    }

    interface CancellationFeeInfo {
        cancellationFee: boolean;
        fee?: {
            currency: string;
            type: string;
            value: number;
        };
    }

    interface TripCancelledInfo {
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
    
    const initialize: (identifier: string, referer: string, organisationId: string, isProduction: boolean) => void
    const getPaymentNonce: (organisationId: string, paymentData: PaymentData) => Promise<PaymentNonce>
    const bookTrip: (passenger: Passenger, quoteId: string, paymentNonce: string) => Promise<TripInfo>
    const cancellationFee: (followCode: string) => Promise<CancellationFeeInfo>
    const cancelTrip: (followCode: string) => Promise<TripCancelledInfo>
}

export = KarhooSdk