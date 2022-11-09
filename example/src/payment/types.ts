export interface PaymentState {
    amount: number;
    currency: Currency | string;
    isLoadingPaymentNonce: boolean;
    paymentNonce?: { nonce: string };
}

// supported currencies
export enum Currency {
    USD = 'USD',
    GBP = 'GBP',
}
