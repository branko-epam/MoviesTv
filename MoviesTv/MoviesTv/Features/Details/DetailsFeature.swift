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
        case trailerLoaded(String?)
        case reviewsLoaded([Review])
        case dismiss
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let mediaId = state.id
                let mediaType = state.mediaType
                return .run { @MainActor [tmdbClient] send in
                    async let creditsTask: Void = {
                        do {
                            let response: CreditsResponse
                            switch mediaType {
                            case .movie:
                                response = try await tmdbClient.fetchMovieCredits(mediaId)
                            case .tvShow:
                                response = try await tmdbClient.fetchTVShowCredits(mediaId)
                            }
                            await send(.castLoaded(response.cast))
                        } catch {
                            print("Error fetching cast: \(error)")
                        }
                    }()

                    async let videosTask: Void = {
                        do {
                            let response: VideosResponse
                            switch mediaType {
                            case .movie:
                                response = try await tmdbClient.fetchMovieVideos(mediaId)
                            case .tvShow:
                                response = try await tmdbClient.fetchTVShowVideos(mediaId)
                            }

                            let trailer = response.results.first { video in
                                video.site == "YouTube" && video.type == "Trailer" && video.official
                            }
                            await send(.trailerLoaded(trailer?.key))
                        } catch {
                            print("Error fetching videos: \(error)")
                        }
                    }()

                    async let reviewsTask: Void = {
                        do {
                            let response: ReviewsResponse
                            switch mediaType {
                            case .movie:
                                response = try await tmdbClient.fetchMovieReviews(mediaId)
                            case .tvShow:
                                response = try await tmdbClient.fetchTVShowReviews(mediaId)
                            }
                            await send(.reviewsLoaded(response.results))
                        } catch {
                            print("Error fetching reviews: \(error)")
                        }
                    }()

                    await creditsTask
                    await videosTask
                    await reviewsTask
                }

            case let .castLoaded(cast):
                state.cast = cast
                return .none

            case let .trailerLoaded(trailerKey):
                state.trailerKey = trailerKey
                return .none

            case let .reviewsLoaded(reviews):
                state.reviews = reviews
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
