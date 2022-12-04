import React from 'react';
import { ActivityIndicator, TouchableOpacityProps } from 'react-native';
import styled from 'styled-components/native';
import { colors } from '../utils';

const StyledButton = styled.TouchableOpacity<{ disabled?: boolean }>`
    ${({ disabled }) => !!disabled && 'opacity: 0.5;'}
    align-items: center;
    background-color: ${colors.indigoDye};
    border-color: ${colors.indigoDye};
    border-radius: 6px;
    border-width: 1px;
    height: 50px;
    height: 60px;
    justify-content: center;
    width: 300px;
`;

const Label = styled.Text`
    color: ${colors.white};
    font-size: 22px;
`;

interface Props extends TouchableOpacityProps {
    label: string;
    loading?: boolean;
}

const Button = ({ label, loading, ...props }: Props) => {
    return (
        <StyledButton {...props} disabled={props.disabled || loading}>
            {loading ? (
                <ActivityIndicator size="large" color={colors.white} />
            ) : (
                <Label>{label}</Label>
            )}
        </StyledButton>
    );
};

export default Button;
