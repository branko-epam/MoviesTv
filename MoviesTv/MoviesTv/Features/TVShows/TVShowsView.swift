import ComposableArchitecture
import SwiftUI

struct TVShowsView: View {
    let store: StoreOf<TVShowsFeature>

    var body: some View {
        NavigationStack {
            VStack {
            }
            .navigationTitle("TV Shows")
        }
    }
}
