declare module 'react-native-config' {
    interface Env {
        KARHOO_ORGANISATION_ID: string;
        KARHOO_REFERER: string;
        KARHOO_IDENTIFIER: string;
    }

    const Config: Env;

    export default Config;
}
