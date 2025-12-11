import Foundation

struct Account: Equatable, @unchecked Sendable {
    let avatar: Avatar
    let id: Int
    let iso639_1: String
    let iso3166_1: String
    let name: String
    let includeAdult: Bool
    let username: String

    struct Avatar: Codable, Equatable, Sendable {
        let gravatar: Gravatar
        let tmdb: TMDBAvatar

        struct Gravatar: Codable, Equatable, Sendable {
            let hash: String
        }

        struct TMDBAvatar: Codable, Equatable, Sendable {
            let avatarPath: String?

            enum CodingKeys: String, CodingKey {
                case avatarPath = "avatar_path"
            }
        }
    }
}

extension Account: Codable {
    enum CodingKeys: String, CodingKey {
        case avatar
        case id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name
        case includeAdult = "include_adult"
        case username
    }
}
