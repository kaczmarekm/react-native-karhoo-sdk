import React from 'react';
import { ScrollView, StyleProp, ViewStyle } from 'react-native';
import styled from 'styled-components/native';
import Button from '../components/Button';
import Input from '../components/Input';
import { useAppDispatch, useAppSelector } from '../hooks';
import { RootState } from '../store';
import { colors } from '../utils';
import { setEmail, setPassword } from './loginSlice';

const Title = styled.Text`
    font-size: 22px;
    font-weight: 600;
    color: ${colors.black};
    margin-vertical: 40px;
`;

const Inputs = styled.View`
    margin-bottom: 30px;
`;

const StyledInput = styled(Input)`
    margin-bottom: 15px;
`;

const StyledButton = styled(Button)`
    margin-top: 15px;
`;

const contentContainerStyle: StyleProp<ViewStyle> = {
    alignItems: 'center',
    justifyContent: 'center',
};

const LoginScreen = () => {
    const email = useAppSelector((state: RootState) => state.registration.email);
    const password = useAppSelector((state: RootState) => state.registration.password);

    const dispatch = useAppDispatch();

    return (
        <ScrollView contentContainerStyle={contentContainerStyle}>
            <Title>Login</Title>
            <Inputs>
                <StyledInput
                    label="Email"
                    value={email}
                    onChangeText={text => dispatch(setEmail(text))}
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

export default LoginScreen;
