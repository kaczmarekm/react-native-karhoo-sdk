import KarhooSdk from '@iteratorsmobile/react-native-karhoo-sdk';
import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import NavigationService from '../Navigator';
import { AppDispatch, RootState } from '../store';
import { Currency, PaymentState } from './types';

const initialState: PaymentState = {
    amount: 0,
    currency: Currency.USD,
    isLoadingPaymentNonce: false,
};

const paymentSlice = createSlice({
    name: 'payment',
    initialState,
    reducers: {
        setAmount: (state: PaymentState, action: PayloadAction<number>) => {
            state.amount = action.payload;
        },
        setCurrency: (state: PaymentState, action: PayloadAction<Currency | string>) => {
            state.currency = action.payload;
        },
        setIsLoadingPaymentNonce: (state: PaymentState, action: PayloadAction<boolean>) => {
            state.isLoadingPaymentNonce = action.payload;
        },
        setPaymentNonce: (state: PaymentState, action: PayloadAction<any>) => {
            state.paymentNonce = action.payload;
        },
    },
});

export const { setAmount, setCurrency, setPaymentNonce, setIsLoadingPaymentNonce } =
    paymentSlice.actions;

export const getPaymentNonceAsyncThunk = createAsyncThunk<
    void,
    undefined,
    { dispatch: AppDispatch; state: RootState; extra: any }
>('payment/getPaymentNonce', async (_, { dispatch, getState }) => {
    try {
        dispatch(setIsLoadingPaymentNonce(true));
        const state = getState();
        const paymentNonce = await KarhooSdk.getPaymentNonce(state.authentication.organisationId, {
            amount: `${state.payment.amount}`,
            currency: state.payment.currency,
        });
        setPaymentNonce(paymentNonce);
        NavigationService.navigate('Trip');
        dispatch(setIsLoadingPaymentNonce(false));
    } catch (error) {
        dispatch(setIsLoadingPaymentNonce(false));
    }
});

export default paymentSlice.reducer;
