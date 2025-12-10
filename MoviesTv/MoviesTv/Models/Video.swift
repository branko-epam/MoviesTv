import Foundation

struct Video: Identifiable, Equatable, @unchecked Sendable {
    let id: String
    let name: String
    let key: String
    let site: String
    let type: String
    let official: Bool
}

extension Video: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case key
        case site
        case type
        case official
    }
}
