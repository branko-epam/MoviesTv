import ComposableArchitecture
import Foundation

extension TMDBClient: DependencyKey {
    static let liveValue = TMDBClient.live
}

extension DependencyValues {
    var tmdbClient: TMDBClient {
        get { self[TMDBClient.self] }
        set { self[TMDBClient.self] = newValue }
    }
}
