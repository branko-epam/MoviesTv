import ComposableArchitecture
import Foundation

@DependencyClient
struct AuthClient {
    var getAccountId: @Sendable () -> Int?
    var setAccountId: @Sendable (Int) -> Void
    var clearAuth: @Sendable () -> Void
    var isAuthenticated: @Sendable () -> Bool = { false }
}

extension AuthClient: DependencyKey {
    static let liveValue: AuthClient = {
        let accountId = LockIsolated<Int?>(nil)

        return Self(
            getAccountId: { accountId.value },
            setAccountId: { id in
                accountId.setValue(id)
            },
            clearAuth: {
                accountId.setValue(nil)
            },
            isAuthenticated: {
                accountId.value != nil
            }
        )
    }()
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
