import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable {
        var searchQuery: String = .init()
        var tvShowCards: IdentifiedArrayOf<CardFeature.State> = []
        var movieCards: IdentifiedArrayOf<CardFeature.State> = []
        var loadedTVShowsPage = 0
        var loadedMoviesPage = 0
        var keywords = KeywordsFeature.State()
        @Presents var details: DetailsFeature.State?
    }

    enum Action {
        case searchQueryChanged(String)
        case onAppear
        case loadMoreTVShows
        case loadMoreMovies
        case tvShowCardsLoaded([CardFeature.State])
        case movieCardsLoaded([CardFeature.State])
        case tvShowCards(IdentifiedActionOf<CardFeature>)
        case movieCards(IdentifiedActionOf<CardFeature>)
        case loadKeywords
        case keywordsLoaded(KeywordsFeature.State)
        case keywords(KeywordsFeature.Action)
        case details(PresentationAction<DetailsFeature.Action>)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.keywords, action: \.keywords) {
            KeywordsFeature()
        }

        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                if query.isEmpty {
                    state.keywords = KeywordsFeature.State()
                    state.tvShowCards = []
                    state.movieCards = []
                    state.loadedTVShowsPage = 0
                    state.loadedMoviesPage = 0
                    return .run { send in
                        await send(.loadMoreTVShows)
                        await send(.loadMoreMovies)
                    }
                } else {
                    return .run {send in
                        await send(.loadKeywords)
                    }
                }

            case .onAppear:
                guard state.loadedTVShowsPage == 0 else { return .none }
                return .run { send in
                    await send(.loadMoreTVShows)
                    await send(.loadMoreMovies)
                }

            case .loadMoreTVShows:
                let nextPage = state.loadedTVShowsPage + 1
                let selectedKeywordId = state.keywords.selectedKeyword?.id
                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response: TMDBResponse<TVShow>
                        if let keywordId = selectedKeywordId {
                            response = try await tmdbClient.discoverTVShows(keywordId, nextPage)
                        } else {
                            response = try await tmdbClient.fetchPopularTVShows(nextPage)
                        }

                        let cards = response.results.map { tvShow in
                            CardFeature.State(
                                id: tvShow.id,
                                title: tvShow.name,
                                coverImagePath: tvShow.posterPath ?? "",
                                overview: tvShow.overview,
                                rating: tvShow.voteAverage,
                                sizeClass: .large,
                                mediaType: .tvShow
                            )
                        }

                        send(.tvShowCardsLoaded(cards))
                    } catch {
                        print("Error fetching TV shows: \(error)")
                    }
                }

            case .loadMoreMovies:
                let nextPage = state.loadedMoviesPage + 1
                let selectedKeywordId = state.keywords.selectedKeyword?.id
                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response: TMDBResponse<Movie>
                        if let keywordId = selectedKeywordId {
                            response = try await tmdbClient.discoverMovies(keywordId, nextPage)
                        } else {
                            response = try await tmdbClient.fetchPopularMovies(nextPage)
                        }

                        let cards = response.results.map { movie in
                            CardFeature.State(
                                id: movie.id,
                                title: movie.title,
                                coverImagePath: movie.posterPath ?? "",
                                overview: movie.overview,
                                rating: movie.voteAverage,
                                sizeClass: .large,
                                mediaType: .movie
                            )
                        }

                        send(.movieCardsLoaded(cards))
                    }
                    catch {
                        print("Error fetching movies: \(error)")
                    }
                }
                
            case let .tvShowCardsLoaded(cards):
                state.tvShowCards.append(contentsOf: cards)
                state.loadedTVShowsPage += 1
                return .none

            case let .movieCardsLoaded(cards):
                state.movieCards.append(contentsOf: cards)
                state.loadedMoviesPage += 1
                return .none
                
            case let .tvShowCards(.element(id: id, action: .openDetails)):
                guard let tvShow = state.tvShowCards[id: id] else { return .none }
                state.details = DetailsFeature.State(
                    id: tvShow.id,
                    mediaType: .tvShow,
                    title: tvShow.title,
                    posterPath: tvShow.coverImagePath,
                    rating: tvShow.rating,
                    overview: tvShow.overview
                )
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

            case .tvShowCards, .movieCards:
                return .none
            case .loadKeywords:
                let query = state.searchQuery
                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response = try await tmdbClient.searchKeyword(query, 1)
                        let keywords = KeywordsFeature.State(
                            keywords: response.results
                        )

                        send(.keywordsLoaded(keywords))
                    } catch {
                        print("Error fetching keywords: \(error)")
                    }
                }

            case let .keywordsLoaded(keywordsState):
                state.keywords = keywordsState
                return .none

            case .keywords(.didSelectKeyword):
                state.tvShowCards = []
                state.movieCards = []
                state.loadedTVShowsPage = 0
                state.loadedMoviesPage = 0
                return .run { send in
                    await send(.loadMoreTVShows)
                    await send(.loadMoreMovies)
                }

            case .keywords:
                return .none

            case .details(.presented(.dismiss)):
                state.details = nil
                return .none

            case .details:
                return .none
            }
        }
        .forEach(\.tvShowCards, action: \.tvShowCards) {
            CardFeature()
        }
        .forEach(\.movieCards, action: \.movieCards) {
            CardFeature()
        }
        .ifLet(\.$details, action: \.details) {
            DetailsFeature()
        }
    }
}
