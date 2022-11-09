import React, { useCallback, useState } from 'react';
import styled from 'styled-components/native';
import Button from '../components/Button';
import Input from '../components/Input';
import { useAppDispatch, useAppSelector } from '../hooks';
import { getPaymentNonceAsyncThunk, setAmount, setCurrency } from './paymentSlice';
import { Currency } from './types';

const Container = styled.View`
    flex: 1;
    align-items: center;
    justify-content: center;
    margin-horizontal: 50px;
`;

const StyledInput = styled(Input)<{ marginBottom: number }>`
    margin-bottom: ${({ marginBottom }) => marginBottom}px;
`;

const CURRENCY_INPUT_HINT = `Available currencies are: ${Object.keys(Currency)}`;

const PaymentScreen = () => {
    const [errors, setErrors] = useState<{ [key: string]: string }>({});

    const amount = useAppSelector(state => state.payment.amount);
    const currency = useAppSelector(state => state.payment.currency);
    const isLoadingPaymentNonce = useAppSelector(state => state.payment.isLoadingPaymentNonce);

    const dispatch = useAppDispatch();
    const handleAmountChange = useCallback(
        (text: string) => {
            dispatch(setAmount(Number(text)));
        },
        [dispatch],
    );
    const handleCurrencyChange = useCallback(
        (text: string) => {
            const currencyText = text.toUpperCase();
            if (currencyText in Currency) {
                setErrors(({ currencyError, ..._errors }) => _errors);
                dispatch(setCurrency(currencyText as Currency));
            } else {
                setErrors(_errors => ({ ..._errors, currencyError: 'Invalid value' }));
                dispatch(setCurrency(currencyText));
            }
        },
        [dispatch, setErrors],
    );

    const handleNextButtonPress = useCallback(() => {
        dispatch(getPaymentNonceAsyncThunk());
    }, [dispatch]);

    return (
        <Container>
            <StyledInput
                value={`${amount}`}
                onChangeText={handleAmountChange}
                label="Amount"
                keyboardType="number-pad"
                marginBottom={10}
            />
            <StyledInput
                value={currency}
                onChangeText={handleCurrencyChange}
                label="Currency"
                keyboardType="number-pad"
                marginBottom={20}
                error={errors.currencyError}
                hint={CURRENCY_INPUT_HINT}
            />
            <Button
                label="Save"
                onPress={handleNextButtonPress}
                disabled={Object.keys(errors).length !== 0}
                loading={isLoadingPaymentNonce}
            />
        </Container>
    );
};

export default PaymentScreen;
