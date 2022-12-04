import React from 'react';
import { ScrollView, StyleProp, ViewStyle } from 'react-native';
import styled from 'styled-components/native';
import Button from '../components/Button';
import Input from '../components/Input';
import { useAppDispatch, useAppSelector } from '../hooks';
import { RootState } from '../store';
import { colors } from '../utils';
import {
    setEmail,
    setFirstName,
    setLastName,
    setLocale,
    setPassword,
    setPhoneNumber,
} from './registrationSlice';

const Title = styled.Text`
    font-size: 22px;
    font-weight: 600;
    color: ${colors.black};
    margin-vertical: 40px;
`;

const Inputs = styled.View`
    display: flex;
    align-self: stretch;
    margin-bottom: 30px;
    align-items: center;
`;

const StyledInput = styled(Input)`
    margin-bottom: 15px;
`;

const StyledButton = styled(Button)`
    margin-top: 15px;
`;

const contentContainerStyle: StyleProp<ViewStyle> = {
    alignItems: 'center',
};

const RegistrationScreen = () => {
    const firstName = useAppSelector((state: RootState) => state.registration.firstName);
    const lastName = useAppSelector((state: RootState) => state.registration.lastName);
    const email = useAppSelector((state: RootState) => state.registration.email);
    const phoneNumber = useAppSelector((state: RootState) => state.registration.phoneNumber);
    const locale = useAppSelector((state: RootState) => state.registration.locale);
    const password = useAppSelector((state: RootState) => state.registration.password);

    const dispatch = useAppDispatch();

    return (
        <ScrollView contentContainerStyle={contentContainerStyle}>
            <Title>Registration</Title>
            <Inputs>
                <StyledInput
                    label="First Name"
                    value={firstName}
                    onChangeText={text => dispatch(setFirstName(text))}
                />
                <StyledInput
                    label="Last Name"
                    value={lastName}
                    onChangeText={text => dispatch(setLastName(text))}
                />
                <StyledInput
                    label="Email"
                    value={email}
                    onChangeText={text => dispatch(setEmail(text))}
                    autoCapitalize="none"
                />
                <StyledInput
                    label="Phone Number"
                    value={phoneNumber}
                    onChangeText={text => dispatch(setPhoneNumber(text))}
                    autoCapitalize="none"
                    keyboardType="number-pad"
                />
                <StyledInput
                    label="Locale"
                    value={locale}
                    onChangeText={text => dispatch(setLocale(text))}
                    autoCapitalize="none"
                />
                <StyledInput
                    label="Password"
                    value={password}
                    onChangeText={text => dispatch(setPassword(text))}
                    secureTextEntry
                    autoCapitalize="none"
                />
                <StyledButton label="Submit" onPress={() => {}} />
            </Inputs>
        </ScrollView>
    );
};

export default RegistrationScreen;
