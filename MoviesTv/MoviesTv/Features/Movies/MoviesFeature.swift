import ComposableArchitecture

@Reducer
struct MoviesFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable {
        var selectedSort: SortOption = .topRated
        var movieCards: IdentifiedArrayOf<CardFeature.State> = []
        var currentPage = 1
        var isLoading = false
        var hasMorePages = true
        @Presents var details: DetailsFeature.State?
    }

    enum Action {
        case sortOptionChanged(SortOption)
        case onAppear
        case loadMovies
        case loadMoreMovies
        case moviesLoaded(TMDBResponse<Movie>)
        case movieCards(IdentifiedActionOf<CardFeature>)
        case details(PresentationAction<DetailsFeature.Action>)
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case topRated = "Top Rated"
        case nowPlaying = "Now Playing"
        case popular = "Popular"

        var id: String { rawValue }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .sortOptionChanged(option):
                state.selectedSort = option
                state.movieCards = []
                state.currentPage = 1
                state.hasMorePages = true
                return .send(.loadMovies)

            case .onAppear:
                guard state.movieCards.isEmpty else { return .none }
                return .send(.loadMovies)

            case .loadMovies:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                let page = state.currentPage
                let sortOption = state.selectedSort

                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response: TMDBResponse<Movie>
                        switch sortOption {
                        case .topRated:
                            response = try await tmdbClient.fetchTopRatedMovies(page)
                        case .nowPlaying:
                            response = try await tmdbClient.fetchNowPlayingMovies(page)
                        case .popular:
                            response = try await tmdbClient.fetchPopularMovies(page)
                        }
                        send(.moviesLoaded(response))
                    } catch {
                        print("Error fetching movies: \(error)")
                    }
                }

            case .loadMoreMovies:
                guard state.hasMorePages && !state.isLoading else { return .none }
                state.currentPage += 1
                return .send(.loadMovies)

            case let .moviesLoaded(response):
                state.isLoading = false
                state.hasMorePages = response.page < response.totalPages

                let newCards = response.results.map { movie in
                    CardFeature.State(
                        id: movie.id,
                        title: movie.title,
                        coverImagePath: movie.posterPath ?? "",
                        overview: movie.overview,
                        rating: movie.voteAverage,
                        sizeClass: .medium
                    )
                }
                state.movieCards.append(contentsOf: newCards)
                return .none

            case let .movieCards(.element(id: id, action: .openDetails)):
                guard let movie = state.movieCards[id: id] else { return .none }
                state.details = DetailsFeature.State(
                    id: movie.id,
                    mediaType: .movie,
                    title: movie.title,
                    posterPath: movie.coverImagePath,
                    rating: movie.rating,
                    overview: movie.overview
                )
                return .none

            case .movieCards:
                return .none

            case .details(.presented(.dismiss)):
                state.details = nil
                return .none

            case .details:
                return .none
            }
        }
        .forEach(\.movieCards, action: \.movieCards) {
            CardFeature()
        }
        .ifLet(\.$details, action: \.details) {
            DetailsFeature()
        }
    }
}
