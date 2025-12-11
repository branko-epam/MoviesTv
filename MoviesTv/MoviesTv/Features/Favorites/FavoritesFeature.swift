import ComposableArchitecture

@Reducer
struct FavoritesFeature {
    @Dependency(\.tmdbClient) var tmdbClient
    @Dependency(\.authClient) var authClient

    @ObservableState
    struct State: Equatable {
        var cards: IdentifiedArrayOf<CardFeature.State> = []
        var currentMoviePage = 1
        var currentTVPage = 1
        var isLoadingMovies = false
        var isLoadingTV = false
        var hasMoreMovies = true
        var hasMoreTV = true
        @Presents var details: DetailsFeature.State?
    }

    enum Action {
        case onAppear
        case loadFavorites
        case loadMoreMovies
        case loadMoreTV
        case moviesLoaded(TMDBResponse<Movie>)
        case tvShowsLoaded(TMDBResponse<TVShow>)
        case cards(IdentifiedActionOf<CardFeature>)
        case details(PresentationAction<DetailsFeature.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.cards.isEmpty else { return .none }
                return .send(.loadFavorites)

            case .loadFavorites:
                return .run { send in
                    await send(.loadMoreMovies)
                    await send(.loadMoreTV)
                }

            case .loadMoreMovies:
                guard !state.isLoadingMovies,
                      state.hasMoreMovies,
                      authClient.isAuthenticated(),
                      let accountId = authClient.getAccountId() else {
                    return .none
                }
                state.isLoadingMovies = true
                let page = state.currentMoviePage

                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response = try await tmdbClient.fetchFavoriteMovies(accountId, page)
                        send(.moviesLoaded(response))
                    } catch {
                        print("Error fetching favorite movies: \(error)")
                    }
                }

            case .loadMoreTV:
                guard !state.isLoadingTV,
                      state.hasMoreTV,
                      authClient.isAuthenticated(),
                      let accountId = authClient.getAccountId() else {
                    return .none
                }
                state.isLoadingTV = true
                let page = state.currentTVPage

                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response = try await tmdbClient.fetchFavoriteTVShows(accountId, page)
                        send(.tvShowsLoaded(response))
                    } catch {
                        print("Error fetching favorite TV shows: \(error)")
                    }
                }

            case let .moviesLoaded(response):
                state.isLoadingMovies = false
                state.hasMoreMovies = response.page < response.totalPages
                state.currentMoviePage += 1

                let newCards = response.results.map { movie in
                    CardFeature.State(
                        id: movie.id,
                        title: movie.title,
                        coverImagePath: movie.posterPath ?? "",
                        overview: movie.overview,
                        rating: movie.voteAverage,
                        sizeClass: .medium,
                        mediaType: .movie
                    )
                }
                state.cards.append(contentsOf: newCards)
                return .none

            case let .tvShowsLoaded(response):
                state.isLoadingTV = false
                state.hasMoreTV = response.page < response.totalPages
                state.currentTVPage += 1

                let newCards = response.results.map { tvShow in
                    CardFeature.State(
                        id: tvShow.id,
                        title: tvShow.name,
                        coverImagePath: tvShow.posterPath ?? "",
                        overview: tvShow.overview,
                        rating: tvShow.voteAverage,
                        sizeClass: .medium,
                        mediaType: .tvShow
                    )
                }
                state.cards.append(contentsOf: newCards)
                return .none

            case let .cards(.element(id: id, action: .openDetails)):
                guard let card = state.cards[id: id] else { return .none }
                let detailsMediaType: DetailsFeature.State.MediaType = card.mediaType == .movie ? .movie : .tvShow
                state.details = DetailsFeature.State(
                    id: card.id,
                    mediaType: detailsMediaType,
                    title: card.title,
                    posterPath: card.coverImagePath,
                    rating: card.rating,
                    overview: card.overview
                )
                return .none

            case .cards:
                return .none

            case .details(.presented(.dismiss)):
                state.details = nil
                return .none

            case .details:
                return .none
            }
        }
        .forEach(\.cards, action: \.cards) {
            CardFeature()
        }
        .ifLet(\.$details, action: \.details) {
            DetailsFeature()
        }
    }
}
