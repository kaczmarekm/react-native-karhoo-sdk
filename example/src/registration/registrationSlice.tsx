import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RegistrationState } from './types';

const initialState: RegistrationState = {
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    locale: '',
    password: '',
};

const registrationSlice = createSlice({
    name: 'registration',
    initialState,
    reducers: {
        setFirstName: (state: RegistrationState, action: PayloadAction<string>) => {
            state.firstName = action.payload;
        },
        setLastName: (state: RegistrationState, action: PayloadAction<string>) => {
            state.lastName = action.payload;
        },
        setEmail: (state: RegistrationState, action: PayloadAction<string>) => {
            state.email = action.payload;
        },
        setPhoneNumber: (state: RegistrationState, action: PayloadAction<string>) => {
            state.phoneNumber = action.payload;
        },
        setLocale: (state: RegistrationState, action: PayloadAction<string>) => {
            state.locale = action.payload;
        },
        setPassword: (state: RegistrationState, action: PayloadAction<string>) => {
            state.password = action.payload;
        },
    },
});

export const { setFirstName, setLastName, setEmail, setPhoneNumber, setLocale, setPassword } =
    registrationSlice.actions;

const registrationReducer = registrationSlice.reducer;

export default registrationReducer;
