import SwiftUI
import ComposableArchitecture
import Kingfisher

struct CardView: View {
    @Bindable var store: StoreOf<CardFeature>
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(store.coverUrl)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            HStack {
                Spacer()
                Text(store.state.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .background(.regularMaterial)
        }
        .frame(width: 200, height: 300)
        .onTapGesture {
            store.send(.openDetails(id: store.id))
        }
    }
}

extension CardView {
    @ViewBuilder
    private func loadedImageView(_ image: Image) -> some View {
        ZStack(alignment: .bottom) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            HStack {
                Spacer()
                Text(store.state.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .background(.regularMaterial)
        }
        .frame(width: 200, height: 300)
    }
    
    @ViewBuilder
    private var errorView: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.largeTitle)
            .foregroundStyle(.red)
    }
}

#Preview {
    CardView(
        store: Store(
            initialState: CardFeature.State(
                id: 66732,
                title: "Stranger Things",
                coverImagePath: "/cVxVGwHce6xnW8UaVUggaPXbmoE.jpg"
            )
        ) {
            CardFeature()
        }
    )
}
