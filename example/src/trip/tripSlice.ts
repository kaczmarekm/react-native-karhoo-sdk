import { createSlice } from '@reduxjs/toolkit';
import { TripState } from './types';

const initialState: TripState = {};

const tripSlice = createSlice({
    name: 'payment',
    initialState,
    reducers: {},
});

export const {} = tripSlice.actions;

const tripReducer = tripSlice.reducer;

export default tripReducer;
