import { configureStore } from '@reduxjs/toolkit';
import authentication from './authentication/authenticationSlice';
import payment from './payment/paymentSlice';

const store = configureStore({
    reducer: {
        authentication,
        payment,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
