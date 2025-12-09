import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable {
        var searchQuery: String = ""
        var tvShowCards: IdentifiedArrayOf<CardFeature.State> = []
        var movieCards: IdentifiedArrayOf<CardFeature.State> = []
        var loadedTVShowsPage = 0
        var loadedMoviesPage = 0
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
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none

            case .onAppear:
                guard state.loadedTVShowsPage == 0 else { return .none }
                return .run { send in
                    await send(.loadMoreTVShows)
                    await send(.loadMoreMovies)
                }

            case .loadMoreTVShows:
                let nextPage = state.loadedTVShowsPage + 1
                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response = try await tmdbClient.fetchPopularTVShows(nextPage)

                        let cards = response.results.map { tvShow in
                            CardFeature.State(
                                id: tvShow.id,
                                title: tvShow.name,
                                coverImagePath: tvShow.posterPath ?? ""
                            )
                        }

                        send(.tvShowCardsLoaded(cards))
                    } catch {
                        print("Error fetching TV shows: \(error)")
                    }
                }

            case .loadMoreMovies:
                let nextPage = state.loadedMoviesPage + 1
                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response = try await tmdbClient.fetchPopularMovies(nextPage)
                        
                        let cards = response.results.map { movie in
                            CardFeature.State(
                                id: movie.id,
                                title: movie.title,
                                coverImagePath: movie.posterPath ?? ""
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
                
            case .tvShowCards, .movieCards:
                return .none
            }
        }
        .forEach(\.tvShowCards, action: \.tvShowCards) {
            CardFeature()
        }
        .forEach(\.movieCards, action: \.movieCards) {
            CardFeature()
        }
    }
}
