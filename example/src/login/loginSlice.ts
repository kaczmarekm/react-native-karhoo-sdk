import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { LoginState } from './types';

const initialState: LoginState = {
    email: '',
    password: '',
};

const loginSlice = createSlice({
    name: 'registration',
    initialState,
    reducers: {
        setEmail: (state: LoginState, action: PayloadAction<string>) => {
            state.email = action.payload;
        },
        setPassword: (state: LoginState, action: PayloadAction<string>) => {
            state.password = action.payload;
        },
    },
});

export const { setEmail, setPassword } = loginSlice.actions;

const loginReducer = loginSlice.reducer;

export default loginReducer;
