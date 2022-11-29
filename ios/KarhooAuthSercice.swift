import KarhooSDK

class KarhooAuthService {
    static let LOGIN_WITH_TOKEN_FAILED = "LOGIN_WITH_TOKEN_FAILED";
    
    static func loginWithToken(_ token: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo
            .getAuthService()
            .login(token: token as String)
            .execute { result in
                switch result {
                    case .success(let user, let correlationId):
                        let resultDict: NSDictionary = [
                            "user": user,
                            "correlationId": correlationId!
                        ]
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooAuthService.LOGIN_WITH_TOKEN_FAILED, nil, errorDict as? Error)
                }
            }
    }
}

