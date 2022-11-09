module.exports = {
    root: true,
    extends: '@react-native-community',
    parser: '@typescript-eslint/parser',
    plugins: ['@typescript-eslint'],
    overrides: [
        {
            files: ['*.ts', '*.tsx'],
            rules: {
                '@typescript-eslint/no-restricted-imports': [
                    'warn',
                    {
                        name: 'react-redux',
                        importNames: ['useSelector', 'useDispatch'],
                        message: 'Use typed hooks `useAppDispatch` and `useAppSelector` instead.',
                    },
                ],
                '@typescript-eslint/no-shadow': ['error'],
                '@typescript-eslint/no-unused-vars': ['error', { ignoreRestSiblings: true }],
                'no-extra-boolean-cast': 'off',
                'no-nested-ternary': 'error',
                'no-restricted-imports': 'off',
                'no-shadow': 'off',
                'no-undef': 'off',
                'no-useless-escape': 'off',
                'react-hooks/exhaustive-deps': 'warn',
                'react-native/no-inline-styles': 'error',
            },
        },
    ],
};
