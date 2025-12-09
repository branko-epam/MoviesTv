import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    tvShowSection
                    movieSection
                    Spacer()
                }
                .listStyle(.plain)
            }
            .navigationTitle("Home")
            .onAppear {
                store.send(.onAppear)
            }
        }
        .searchable(text: $store.searchQuery.sending(\.searchQueryChanged), prompt: "Search items")
    }
}

extension HomeView {
    @ViewBuilder
    private var tvShowSection: some View {
        Section("Trending TV Shows") {
            if store.tvShowCards.isEmpty {
                ProgressView("Loading...")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(store.scope(state: \.tvShowCards, action: \.tvShowCards)) { cardStore in
                            CardView(store: cardStore)
                                .onAppear {
                                    if cardStore.id == store.tvShowCards.last?.id {
                                        store.send(.loadMoreTVShows)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private var movieSection: some View {
        Section("Trending Movies") {
            if store.movieCards.isEmpty {
                ProgressView("Loading...")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(store.scope(state: \.movieCards, action: \.movieCards)) { cardStore in
                            CardView(store: cardStore)
                                .onAppear {
                                    if cardStore.id == store.movieCards.last?.id {
                                        store.send(.loadMoreMovies)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
