import Foundation

struct ReviewsResponse: Equatable, @unchecked Sendable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    let totalResults: Int
}

extension ReviewsResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
