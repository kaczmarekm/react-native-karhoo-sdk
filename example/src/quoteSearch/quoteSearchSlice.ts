import { createSlice } from '@reduxjs/toolkit';
import { QuoteSearchState } from './types';

const initialState: QuoteSearchState = {};

const quoteSearchSlice = createSlice({
    name: 'payment',
    initialState,
    reducers: {},
});

export const {} = quoteSearchSlice.actions;

export default quoteSearchSlice.reducer;
