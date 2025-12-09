import Foundation

struct TMDBResponse<T: Codable>: Codable, @unchecked Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
