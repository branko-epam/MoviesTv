import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var movies = MoviesFeature.State()
        var tvShows = TVShowsFeature.State()
        var favorites = FavoritesFeature.State()
    }

    enum Action {
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case movies(MoviesFeature.Action)
        case tvShows(TVShowsFeature.Action)
        case favorites(FavoritesFeature.Action)
    }

    enum Tab {
        case home
        case movies
        case tvShows
        case favorites
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Scope(state: \.movies, action: \.movies) {
            MoviesFeature()
        }

        Scope(state: \.tvShows, action: \.tvShows) {
            TVShowsFeature()
        }

        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .home, .movies, .tvShows, .favorites:
                return .none
            }
        }
    }
}
