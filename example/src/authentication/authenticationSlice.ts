import KarhooSdk from '@iteratorsmobile/react-native-karhoo-sdk';
import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import NavigationService from '../Navigator';
import { AppDispatch, RootState } from '../store';
import { AuthenticationState } from './types';

const initialState: AuthenticationState = {
    identifier: '',
    referer: '',
    organisationId: '',
};

const authenticationSlice = createSlice({
    name: 'authentication',
    initialState,
    reducers: {
        setIdentifier: (state: AuthenticationState, action: PayloadAction<string>) => {
            state.identifier = action.payload;
        },
        setReferer: (state: AuthenticationState, action: PayloadAction<string>) => {
            state.referer = action.payload;
        },
        setOrganisationId: (state: AuthenticationState, action: PayloadAction<string>) => {
            state.organisationId = action.payload;
        },
    },
});

export const { setIdentifier, setReferer, setOrganisationId } = authenticationSlice.actions;

export const authenticate = createAsyncThunk<
    void,
    undefined,
    { dispatch: AppDispatch; state: RootState; extra: any }
>('payment/getPaymentNonce', async (_, { getState }) => {
    const {
        authentication: { identifier, referer, organisationId },
    } = getState();
    KarhooSdk.initialize(identifier, referer, organisationId, false);
    NavigationService.navigate('Payment');
});

export default authenticationSlice.reducer;
