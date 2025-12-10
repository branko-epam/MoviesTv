import Foundation
import ComposableArchitecture

@Reducer
struct DetailsFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable, Identifiable {
        let id: Int
        let mediaType: MediaType
        var title: String
        var posterPath: String?
        var rating: Double
        var overview: String
        var trailerKey: String?
        var cast: [CastMember] = []
        var reviews: [Review] = []

        enum MediaType: Equatable {
            case movie
            case tvShow
        }
    }

    enum Action: Equatable {
        case onAppear
        case castLoaded([CastMember])
        case dismiss
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let mediaId = state.id
                let mediaType = state.mediaType
                return .run { @MainActor [tmdbClient] send in
                    do {
                        let response: CreditsResponse
                        switch mediaType {
                        case .movie:
                            response = try await tmdbClient.fetchMovieCredits(mediaId)
                        case .tvShow:
                            response = try await tmdbClient.fetchTVShowCredits(mediaId)
                        }
                        send(.castLoaded(response.cast))
                    } catch {
                        print("Error fetching cast: \(error)")
                    }
                }

            case let .castLoaded(cast):
                state.cast = cast
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
