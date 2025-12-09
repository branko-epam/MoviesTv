import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var searchQuery: String = ""
    }

    enum Action {
        case searchQueryChanged(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none
            }
        }
    }
}
