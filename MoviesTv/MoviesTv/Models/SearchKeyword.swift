import Foundation

struct SearchKeyword: Identifiable, Equatable, @unchecked Sendable {
    let id: Int
    let name: String
}

extension SearchKeyword: Codable {
}
