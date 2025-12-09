import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppFeature.Tab.home)

            MoviesView(store: store.scope(state: \.movies, action: \.movies))
                .tabItem {
                    Label("Movies", systemImage: "film.fill")
                }
                .tag(AppFeature.Tab.movies)

            TVShowsView(store: store.scope(state: \.tvShows, action: \.tvShows))
                .tabItem {
                    Label("TV Shows", systemImage: "tv.fill")
                }
                .tag(AppFeature.Tab.tvShows)

            FavoritesView(store: store.scope(state: \.favorites, action: \.favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(AppFeature.Tab.favorites)
        }
    }
}
