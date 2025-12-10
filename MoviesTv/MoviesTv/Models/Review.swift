import Foundation

struct Review: Identifiable, Equatable, @unchecked Sendable {
    let id: String
    let author: String
    let content: String
    let rating: Double?
    let createdAt: String

    struct AuthorDetails: Codable, Equatable, Sendable {
        let rating: Double?
    }
}

extension Review: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case content
        case authorDetails = "author_details"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        author = try container.decode(String.self, forKey: .author)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(String.self, forKey: .createdAt)

        let authorDetails = try container.decode(AuthorDetails.self, forKey: .authorDetails)
        rating = authorDetails.rating
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(AuthorDetails(rating: rating), forKey: .authorDetails)
    }
}
