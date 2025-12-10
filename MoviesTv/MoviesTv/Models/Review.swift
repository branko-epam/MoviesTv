import Foundation

struct Review: Identifiable, Equatable, @unchecked Sendable {
    let id: String
    let author: String
    let content: String
    let rating: Double?
    let createdAt: String
}

extension Review: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case content
        case rating
        case createdAt = "created_at"
    }
}
