import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable {
        var searchQuery: String = ""
        var cards: IdentifiedArrayOf<CardFeature.State> = []
        var loadedTVShowsPage = 0
        var loadedMoviesPage = 0
    }

    enum Action {
        case searchQueryChanged(String)
        case onAppear
        case loadMoreTVShows
        case cardsLoaded([CardFeature.State])
        case cards(IdentifiedActionOf<CardFeature>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none

            case .onAppear:
                guard state.loadedTVShowsPage == 0 else { return .none }
                return .send(.loadMoreTVShows)

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

                        send(.cardsLoaded(cards))
                    } catch {
                        print("Error fetching TV shows: \(error)")
                    }
                }

            case let .cardsLoaded(cards):
                state.cards.append(contentsOf: cards)
                state.loadedTVShowsPage += 1
                return .none

            case .cards:
                return .none
            }
        }
        .forEach(\.cards, action: \.cards) {
            CardFeature()
        }
    }
}
