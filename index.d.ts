export interface GetPaymentNonceResponse {
    nonce: string;
}

export interface BookTripResponse {
    tripId: string;
}

export interface CancelTripResponse {
    tripCancelled: true;
}

export interface PaymentData {
    currency: string;
    amount: string;
}

export interface Passenger {
    firstName: string;
    lastName: string;
    email: string;
    mobileNumber: string;
    locale: string;
}

export default {
    initialize: (identifier: string, referer: string, organisationId: string): void => {},
    getPaymentNonce: (organisationId: string, paymentData: PaymentData): Promise<GetPaymentNonceResponse | any> => {},
    bookTrip: (passenger: Passenger, quoteId: string, paymentNonce: string): Promise<BookTripResponse | any> => {},
    cancelTrip: (tripId: string): Promise<CancelTripResponse | any> => {}
}