import { configureStore } from '@reduxjs/toolkit';
import loginReducer from './login/loginSlice';
import registrationReducer from './registration/registrationSlice';

const store = configureStore({
    reducer: {
        registration: registrationReducer,
        login: loginReducer,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
