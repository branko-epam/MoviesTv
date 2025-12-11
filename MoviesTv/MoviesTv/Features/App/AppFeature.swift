import ComposableArchitecture

@Reducer
struct AppFeature {
    @Dependency(\.tmdbClient) var tmdbClient
    @Dependency(\.authClient) var authClient

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var movies = MoviesFeature.State()
        var tvShows = TVShowsFeature.State()
        var favorites = FavoritesFeature.State()
        var isLoadingAuth = false
    }

    enum Action {
        case onAppear
        case loadAuth
        case authLoaded(accountId: Int)
        case authLoadFailed
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
            case .onAppear:
                guard !authClient.isAuthenticated() else {
                    return .none
                }
                return .send(.loadAuth)

            case .loadAuth:
                guard !state.isLoadingAuth else { return .none }
                state.isLoadingAuth = true
                return .run {@MainActor [tmdbClient, authClient] send in
                    do {
                        let account = try await tmdbClient.fetchAccount()
                        authClient.setAccountId(account.id)
                        send(.authLoaded(accountId: account.id))
                    } catch {
                        print("Error loading auth: \(error)")
                        send(.authLoadFailed)
                    }
                }

            case let .authLoaded(accountId):
                state.isLoadingAuth = false
                print("Authenticated with account ID: \(accountId)")
                return .none

            case .authLoadFailed:
                state.isLoadingAuth = false
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .home, .movies, .tvShows, .favorites:
                return .none
            }
        }
    }
}
