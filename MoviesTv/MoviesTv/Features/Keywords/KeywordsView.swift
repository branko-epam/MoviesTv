import SwiftUI
import ComposableArchitecture

struct KeywordsView: View {
    @Bindable var store: StoreOf<KeywordsFeature>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.keywords) { keyword in
                    KeywordPill(
                        name: keyword.name,
                        isSelected: store.selectedKeyword?.id == keyword.id
                    ) {
                        store.send(.didSelectKeyword(keyword))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct KeywordPill: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    KeywordsView(
        store: Store(
            initialState: KeywordsFeature.State(
                keywords: [
                    SearchKeyword(id: 1, name: "Action"),
                    SearchKeyword(id: 2, name: "Comedy"),
                    SearchKeyword(id: 3, name: "Drama"),
                    SearchKeyword(id: 4, name: "Science Fiction")
                ],
                selectedKeyword: SearchKeyword(id: 1, name: "Action")
            )
        ) {
            KeywordsFeature()
        }
    )
}
