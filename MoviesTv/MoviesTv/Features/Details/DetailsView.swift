import SwiftUI
import ComposableArchitecture

struct DetailsView: View {
    @Bindable var store: StoreOf<DetailsFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                posterSection
                titleAndRatingSection
                overviewSection
                if store.trailerKey != nil {
                    trailerSection
                }
                if !store.cast.isEmpty {
                    castSection
                }
                if !store.reviews.isEmpty {
                    reviewsSection
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    store.send(.dismiss)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension DetailsView {
    @ViewBuilder
    private var posterSection: some View {
        if let posterPath = store.posterPath,
           let baseUrl = Bundle.main.infoDictionary?["MDB_IMG_URL"] as? String,
           let url = URL(string: baseUrl + posterPath) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                case .failure:
                    Color.gray
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(12)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(2/3, contentMode: .fit)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private var titleAndRatingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.title)
                .font(.title)
                .bold()

            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", store.rating))
                    .font(.headline)
                Text("/ 10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            Text(store.overview)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trailer")
                .font(.headline)

            if let trailerKey = store.trailerKey,
               let url = URL(string: "https://www.youtube.com/watch?v=\(trailerKey)") {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                        Text("Watch Trailer")
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }

    @ViewBuilder
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.cast) { member in
                        VStack {
                            if let profilePath = member.profilePath,
                               let baseUrl = Bundle.main.infoDictionary?["MDB_IMG_URL"] as? String,
                               let url = URL(string: baseUrl + profilePath) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                    case .failure, .empty:
                                        Circle()
                                            .fill(Color.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 80, height: 80)
                            } else {
                                Circle()
                                    .fill(Color.gray)
                            }

                            Text(member.name)
                                .font(.caption)
                                .bold()
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)

                            Text(member.character)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.headline)

            ForEach(store.reviews) { review in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(review.author)
                            .font(.subheadline)
                            .bold()

                        Spacer()

                        if let rating = review.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption)
                            }
                        }
                    }

                    Text(review.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)

                    Text(review.createdAt)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailsView(
            store: Store(
                initialState: DetailsFeature.State(
                    id: 1,
                    mediaType: .movie,
                    title: "Sample Movie",
                    posterPath: "/sample.jpg",
                    rating: 8.5,
                    overview: "This is a sample overview of the movie. It provides a brief description of the plot and main themes.",
                    trailerKey: "dQw4w9WgXcQ",
                    cast: [
                        CastMember(id: 1, name: "John Doe", character: "Hero", profilePath: nil),
                        CastMember(id: 2, name: "Jane Smith", character: "Villain", profilePath: nil)
                    ],
                    reviews: [
                        Review(id: "1", author: "Reviewer1", content: "Great movie! Really enjoyed it.", rating: 9.0, createdAt: "2024-01-01"),
                        Review(id: "2", author: "Reviewer2", content: "Not bad, but could be better.", rating: 7.0, createdAt: "2024-01-02")
                    ]
                )
            ) {
                DetailsFeature()
            }
        )
    }
}
