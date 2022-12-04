import React, { useCallback } from 'react';
import { Alert, TextInputProps } from 'react-native';
import styled from 'styled-components/native';
import { colors } from '../utils';

const Container = styled.View`
    width: 300px;
`;

const Row = styled.View`
    align-items: center;
    flex-direction: row;
    margin-bottom: 6px;
`;

const Label = styled.Text<{ hasError: boolean }>`
    color: ${({ hasError }) => (hasError ? colors.orangeRedCrayola : colors.grayWeb)};
    font-size: 18px;
`;

const HintButton = styled.TouchableOpacity`
    align-items: center;
    justify-content: center;
    width: 16px;
    height: 16px;
    border-radius: 8px;
    border-width: 1px;
    border-color: ${colors.grayWeb};
    background-color: ${colors.grayWeb};
    margin-left: 10px;
`;

const HintButtonText = styled.Text`
    font-size: 12px;
    color: ${colors.white};
    margin-left: 1px;
`;

const StyledInput = styled.TextInput<{ hasError: boolean }>`
    align-self: stretch;
    border-color: ${({ hasError }) => (hasError ? colors.orangeRedCrayola : colors.black)};
    border-radius: 6px;
    border-width: 1px;
    color: ${colors.black};
    font-size: 22px;
    height: 50px;
    padding-horizontal: 15px;
`;

interface Props extends TextInputProps {
    label: string;
    error?: string;
    hint?: string;
}

const Input = ({ label, error, hint, ...props }: Props) => {
    const displayHint = useCallback(() => {
        if (!hint) {
            return;
        }
        Alert.alert(hint);
    }, [hint]);

    return (
        <Container>
            <Row>
                <Label hasError={!!error}>
                    {label}
                    {error ? ` - ${error}` : ''}
                </Label>
                {hint && (
                    <HintButton onPress={displayHint}>
                        <HintButtonText>!</HintButtonText>
                    </HintButton>
                )}
            </Row>
            <StyledInput {...props} hasError={!!error} />
        </Container>
    );
};

export default Input;
