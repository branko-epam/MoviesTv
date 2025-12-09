import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            VStack {
                if store.cards.isEmpty {
                    ProgressView("Loading...")
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
                                CardView(store: cardStore)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
