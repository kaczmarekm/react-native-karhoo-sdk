import { NavigationContainer, NavigationContainerRef } from '@react-navigation/native';
import {
    createNativeStackNavigator,
    NativeStackNavigationOptions,
} from '@react-navigation/native-stack';
import React, { createRef } from 'react';
import QuoteSearch from './quoteSearch/QuoteSearchScreen';
import Trip from './trip/TripScreen';
import { colors } from './utils';

const Stack = createNativeStackNavigator();

interface NavigationParams {
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
        <Stack.Navigator initialRouteName="QuoteSearch" screenOptions={stackNavigatorOptions}>
            <Stack.Screen name="QuoteSearch" component={QuoteSearch} />
            <Stack.Screen name="Trip" component={Trip} />
        </Stack.Navigator>
    </NavigationContainer>
);

const NavigationService = {
    navigate: (routeName: keyof NavigationParams) => navigationRef.current?.navigate(routeName),
    goBack: () => navigationRef.current?.goBack(),
};

export default NavigationService;
