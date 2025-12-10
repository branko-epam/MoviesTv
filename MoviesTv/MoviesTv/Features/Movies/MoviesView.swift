import ComposableArchitecture
import SwiftUI

struct MoviesView: View {
    @Bindable var store: StoreOf<MoviesFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Sort", selection: $store.selectedSort.sending(\.sortOptionChanged)) {
                    ForEach(MoviesFeature.SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(Array(store.scope(state: \.movieCards, action: \.movieCards))) { cardStore in
                            CardView(store: cardStore)
                                .onAppear {
                                    if cardStore.id == store.movieCards.last?.id {
                                        store.send(.loadMoreMovies)
                                    }
                                }
                        }
                    }
                    .padding()

                    if store.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .navigationTitle("Movies")
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
