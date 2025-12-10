import ComposableArchitecture
import SwiftUI

struct TVShowsView: View {
    @Bindable var store: StoreOf<TVShowsFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Sort", selection: $store.selectedSort.sending(\.sortOptionChanged)) {
                    ForEach(TVShowsFeature.SortOption.allCases) { option in
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
                        ForEach(Array(store.scope(state: \.tvShowCards, action: \.tvShowCards))) { cardStore in
                            CardView(store: cardStore)
                                .onAppear {
                                    if cardStore.id == store.tvShowCards.last?.id {
                                        store.send(.loadMoreTVShows)
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
            .navigationTitle("TV Shows")
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
