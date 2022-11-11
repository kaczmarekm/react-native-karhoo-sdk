module.exports = {
    preset: 'react-native',
    setupFilesAfterEnv: ['./src/__tests__/setup.ts'],
    testMatch: [
        '**/__tests__/**/*\\.(spec|test)\\.ts?(x)',
        '**/scripts/**/*\\.(spec|test)\\.ts?(x)',
        '**/src/**/*\\.(spec|test)\\.ts?(x)',
    ],
    transformIgnorePatterns: [
        'node_modules/(?!((jest-)?react-native|@react-native|react-navigation|@react-navigation/.*))',
    ],
};
