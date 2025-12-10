import Foundation

struct CreditsResponse: Equatable, @unchecked Sendable {
    let id: Int
    let cast: [CastMember]
}

extension CreditsResponse: Codable {
}
