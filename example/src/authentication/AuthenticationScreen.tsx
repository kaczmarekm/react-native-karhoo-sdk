import { useCallback, useMemo } from 'react';
import styled from 'styled-components/native';
import Button from '../components/Button';
import Input from '../components/Input';
import { useAppDispatch, useAppSelector } from '../hooks';
import { authenticate, setIdentifier, setOrganisationId, setReferer } from './authenticationSlice';

const Container = styled.View`
    flex: 1;
    margin-bottom: 40px;
    margin-horizontal: 40px;
    align-items: center;
`;

const InputContainer = styled.View`
    flex: 1;
    align-self: stretch;
    align-items: center;
    justify-content: center;
    padding-top: 40px;
`;

const StyledInput = styled(Input)<{ marginBottom: number }>`
    margin-bottom: ${({ marginBottom }) => marginBottom}px;
`;

const AuthenticationScreen = () => {
    const identifier = useAppSelector(state => state.authentication.identifier);
    const referer = useAppSelector(state => state.authentication.referer);
    const organisationId = useAppSelector(state => state.authentication.organisationId);

    const dispatch = useAppDispatch();
    const handleIdentifierChange = useCallback(
        (text: string) => {
            dispatch(setIdentifier(text));
        },
        [dispatch],
    );
    const handleRefererChange = useCallback(
        (text: string) => {
            dispatch(setReferer(text));
        },
        [dispatch],
    );
    const handleOrganisationIdChange = useCallback(
        (text: string) => {
            dispatch(setOrganisationId(text));
        },
        [dispatch],
    );

    const nextButtonDisabled = useMemo(
        () => !identifier || !referer || !organisationId,
        [identifier, referer, organisationId],
    );

    const handleNextButtonPress = useCallback(() => {
        dispatch(authenticate());
    }, [dispatch]);

    return (
        <Container>
            <InputContainer>
                <StyledInput
                    value={identifier}
                    onChangeText={handleIdentifierChange}
                    label="Identifier"
                    marginBottom={15}
                />
                <StyledInput
                    value={referer}
                    onChangeText={handleRefererChange}
                    label="Referer"
                    marginBottom={15}
                />
                <StyledInput
                    value={organisationId}
                    onChangeText={handleOrganisationIdChange}
                    label="Organisation Id"
                    marginBottom={50}
                />
            </InputContainer>
            <Button label="Next" onPress={handleNextButtonPress} disabled={nextButtonDisabled} />
        </Container>
    );
};

export default AuthenticationScreen;
