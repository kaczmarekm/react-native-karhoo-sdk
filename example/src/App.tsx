import React from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import { Provider } from 'react-redux';
import { Navigator } from './Navigator';
import store from './store';

const App = () => (
    <Provider store={store}>
        <SafeAreaView style={StyleSheet.absoluteFill}>
            <Navigator />
        </SafeAreaView>
    </Provider>
);

export default App;
