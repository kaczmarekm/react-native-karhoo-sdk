export interface GetPaymentNonceResponse {
    nonce: string;
}

export interface BookTripResponse {
    tripId: string;
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
    getPaymentNonce: (organisationId: string, currency: string): Promise<GetPaymentNonceResponse | null> => {},
    bookTrip: (userInfo: Passenger, quoteId: string, paymentNonce: string): Promise<BookTripResponse | null> => {}
}