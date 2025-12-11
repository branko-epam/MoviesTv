import ComposableArchitecture
import SwiftUI

struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

    var body: some View {
        NavigationStack {
            ScrollView {
                if store.cards.isEmpty && !store.isLoadingMovies && !store.isLoadingTV {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("You don't have favorites")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(Array(store.scope(state: \.cards, action: \.cards))) { cardStore in
                            CardView(store: cardStore)
                                .onAppear {
                                    if cardStore.id == store.cards.last?.id {
                                        store.send(.loadMoreMovies)
                                        store.send(.loadMoreTV)
                                    }
                                }
                        }
                    }
                    .padding()

                    if store.isLoadingMovies || store.isLoadingTV {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                store.send(.onAppear)
            }
        }
        .sheet(item: $store.scope(state: \.details, action: \.details)) { detailsStore in
            NavigationStack {
                DetailsView(store: detailsStore)
            }
        }
    }
}
