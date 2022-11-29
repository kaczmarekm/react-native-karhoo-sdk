import KarhooSDK

class KarhooUserService: NSObject {
    static let REGISTRATION_FAILED = "REGISTRATION_FAILED";
    static let LOGIN_FAILED = "LOGIN_FAILED";
    static let LOGOUT_FAILED = "LOGOUT_FAILED";
    static let CURRENT_USER_FAILED = "CURRENT_USER_FAILED";

    static func register(_ registrationData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let userRegistration = UserRegistration(
            firstName: registrationData["firstName"] as! String,
            lastName: registrationData["lastName"] as! String,
            email: registrationData["email"] as! String,
            phoneNumber: registrationData["phoneNumber"] as! String,
            locale: registrationData["locale"] as? String,
            password: registrationData["password"] as! String
        );
        Karhoo
            .getUserService()
            .register(userRegistration: userRegistration)
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
                        reject(KarhooUserService.REGISTRATION_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func login(_ loginData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let userLogin = UserLogin(
            username: loginData["username"] as! String,
            password: loginData["password"] as! String
        );
        Karhoo
            .getUserService()
            .login(userLogin: userLogin)
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
                        reject(KarhooUserService.LOGIN_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func logout(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        Karhoo
            .getUserService()
            .logout()
            .execute { result in
                switch result {
                    case .success(_, let correlationId):
                        let resultDict: NSDictionary = [
                            "success": true,
                            "correlationId": correlationId!
                        ]
                        resolve(resultDict)
                    case .failure(let error, let correlationId):
                        let errorDict: NSDictionary = [
                            "error": error!.message as String,
                            "correlationId": correlationId!
                        ]
                        reject(KarhooUserService.LOGOUT_FAILED, nil, errorDict as? Error)
                }
            }
    }

    static func currentUser(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        if let user = Karhoo
            .getUserService()
            .getCurrentUser() {
                        let resultDict: NSDictionary = [
                            "user": user                            
                        ]
                        resolve(resultDict)
                
                
            }
    }
}
