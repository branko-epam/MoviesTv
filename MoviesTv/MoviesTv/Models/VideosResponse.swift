import Foundation

struct VideosResponse: Equatable, @unchecked Sendable {
    let id: Int
    let results: [Video]
}

extension VideosResponse: Codable {
}
