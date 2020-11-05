import KarhooSDK

@main
@objc(KarhooConfig)
class KarhooConfig: NSObject {
    @objc(initialize:referer:organisationId:)
    func initialize(identifier: String, referer: String, organisationId: String) -> Void {
        Karhoo.set(configuration: KarhooConfiguration(identifier: identifier, referer: referer, organisationId: organisationId))
    }
}

struct KarhooConfiguration: KarhooSDKConfiguration {    
    var identifier: String
    var referer: String
    var organisationId: String

    init (identifier: String, referer: String, organisationId: String) {
        self.identifier = identifier
        self.referer = referer
        self.organisationId = organisationId
    }

    func environment() -> KarhooEnvironment {
        return .sandbox
    }

    func authenticationMethod() -> AuthenticationMethod {
        return .guest(settings: GuestSettings(self.identifier, self.referer, self.organisationId))
    }
}