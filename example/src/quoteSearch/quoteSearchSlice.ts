import { createSlice } from '@reduxjs/toolkit';
import { QuoteSearchState } from './types';

const initialState: QuoteSearchState = {};

const quoteSearchSlice = createSlice({
    name: 'quoteSearch',
    initialState,
    reducers: {},
});

export const {} = quoteSearchSlice.actions;

const quoteSearchReducer = quoteSearchSlice.reducer;

export default quoteSearchReducer;
