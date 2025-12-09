import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var searchQuery: String = ""
        var cards: IdentifiedArrayOf<CardFeature.State> = []
    }

    enum Action {
        case searchQueryChanged(String)
        case onAppear
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
                return .run { send in
                    try await Task.sleep(for: .seconds(1))

                    let mockCards = [
                        CardFeature.State(
                            id: 66732,
                            title: "Stranger Things",
                            coverImagePath: "/cVxVGwHce6xnW8UaVUggaPXbmoE.jpg"
                        ),
                        CardFeature.State(
                            id: 1399,
                            title: "Game of Thrones",
                            coverImagePath: "/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg"
                        ),
                        CardFeature.State(
                            id: 1396,
                            title: "Breaking Bad",
                            coverImagePath: "/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg"
                        )
                    ]

                    await send(.cardsLoaded(mockCards))
                }

            case let .cardsLoaded(cards):
                state.cards = IdentifiedArray(uniqueElements: cards)
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
