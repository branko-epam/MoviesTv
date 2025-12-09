import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            VStack {
            }
            .navigationTitle("Home")
        }
    }
}
