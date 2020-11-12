interface GetPaymentNonceResponse {
    nonce: string;
}

interface BookTripResponse {
    tripId: string;
}

interface UserInfo {
    firstName: string;
    lastName: string;
    email: string;
    mobileNumber: string;
    locale: string;
}

export default {
    initialize: (identifier: string, referer: string, organisationId: string): void => {},
    getPaymentNonce: (organisationId: string, currency: string): Promise<GetPaymentNonceResponse | null> => {},
    bookTrip: (userInfo: UserInfo, quoteId: string, paymentNonce: string): Promise<BookTripResponse | null> => {}
}