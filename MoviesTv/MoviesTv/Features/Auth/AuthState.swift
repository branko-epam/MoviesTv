import Foundation

struct AuthState: Equatable, Codable, Sendable {
    var accountId: Int?
    var sessionId: String?

    var isAuthenticated: Bool {
        accountId != nil && sessionId != nil
    }

    enum CodingKeys: String, CodingKey {
        case accountId
        case sessionId
    }
}
