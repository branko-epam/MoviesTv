import Foundation

struct CastMember: Identifiable, Equatable, @unchecked Sendable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
}

extension CastMember: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}
