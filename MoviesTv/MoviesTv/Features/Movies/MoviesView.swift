import ComposableArchitecture
import SwiftUI

struct MoviesView: View {
    let store: StoreOf<MoviesFeature>

    var body: some View {
        NavigationStack {
            VStack {
            }
            .navigationTitle("Movies")
        }
    }
}
