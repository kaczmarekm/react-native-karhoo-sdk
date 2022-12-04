import { NavigationContainer, NavigationContainerRef } from '@react-navigation/native';
import {
    createNativeStackNavigator,
    NativeStackNavigationOptions,
} from '@react-navigation/native-stack';
import React, { createRef } from 'react';
import LoginScreen from './login/LoginScreen';
import QuoteSearchScreen from './quoteSearch/QuoteSearchScreen';
import RegistrationScreen from './registration/RegistrationScreen';
import TripScreen from './trip/TripScreen';
import { colors } from './utils';

const Stack = createNativeStackNavigator();

interface NavigationParams {
    Registration: undefined;
    Login: undefined;
    QuoteSearch: undefined;
    Trip: undefined;
}

const navigationRef = createRef<NavigationContainerRef<NavigationParams>>();

const stackNavigatorOptions: NativeStackNavigationOptions = {
    headerShown: false,
    contentStyle: {
        backgroundColor: colors.white,
    },
};

export const Navigator = () => (
    <NavigationContainer ref={navigationRef}>
        <Stack.Navigator initialRouteName="Registration" screenOptions={stackNavigatorOptions}>
            <Stack.Screen name="Registration" component={RegistrationScreen} />
            <Stack.Screen name="Login" component={LoginScreen} />
            <Stack.Screen name="QuoteSearch" component={QuoteSearchScreen} />
            <Stack.Screen name="Trip" component={TripScreen} />
        </Stack.Navigator>
    </NavigationContainer>
);

const NavigationService = {
    navigate: (routeName: keyof NavigationParams) => navigationRef.current?.navigate(routeName),
    goBack: () => navigationRef.current?.goBack(),
};

export default NavigationService;
