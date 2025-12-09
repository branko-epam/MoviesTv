import ComposableArchitecture

@Reducer
struct MoviesFeature {
    @ObservableState
    struct State: Equatable {
        var selectedSort: SortOption = .popular
    }

    enum Action {
        case sortOptionChanged(SortOption)
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
                return .none
            }
        }
    }
}
