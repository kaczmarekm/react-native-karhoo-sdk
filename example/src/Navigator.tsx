import { NavigationContainer, NavigationContainerRef } from '@react-navigation/native';
import {
    createNativeStackNavigator,
    NativeStackNavigationOptions,
} from '@react-navigation/native-stack';
import React, { createRef } from 'react';
import AuthenticationScreen from './authentication/AuthenticationScreen';
import PaymentScreen from './payment/PaymentScreen';
import Trip from './trip/TripScreen';
import { colors } from './utils';

const Stack = createNativeStackNavigator();

interface NavigationParams {
    Authentication: undefined;
    Payment: undefined;
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
        <Stack.Navigator initialRouteName="Authentication" screenOptions={stackNavigatorOptions}>
            <Stack.Screen name="Authentication" component={AuthenticationScreen} />
            <Stack.Screen name="Payment" component={PaymentScreen} />
            <Stack.Screen name="Trip" component={Trip} />
        </Stack.Navigator>
    </NavigationContainer>
);

const NavigationService = {
    navigate: (routeName: keyof NavigationParams) => navigationRef.current?.navigate(routeName),
    goBack: () => navigationRef.current?.goBack(),
};

export default NavigationService;
