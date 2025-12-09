import ComposableArchitecture

@Reducer
struct FavoritesFeature {
    @ObservableState
    struct State: Equatable {
    }

    enum Action {
        case removeFavorite(id: Int)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .removeFavorite(id):
                return .none
            }
        }
    }
}
