import mockReactNativeKarhooSdk from '@iteratorsmobile/react-native-karhoo-sdk/jestMock';

jest.useFakeTimers();

jest.mock('@iteratorsmobile/react-native-karhoo-sdk', () => mockReactNativeKarhooSdk);
