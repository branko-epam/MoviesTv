import ComposableArchitecture

@Reducer
struct TVShowsFeature {
    @Dependency(\.tmdbClient) var tmdbClient

    @ObservableState
    struct State: Equatable {
        var selectedSort: SortOption = .topRated
        var tvShowCards: IdentifiedArrayOf<CardFeature.State> = []
        var currentPage = 1
        var isLoading = false
        var hasMorePages = true
        @Presents var details: DetailsFeature.State?
    }

    enum Action {
        case sortOptionChanged(SortOption)
        case onAppear
        case loadTVShows
        case loadMoreTVShows
        case tvShowsLoaded(TMDBResponse<TVShow>)
        case tvShowCards(IdentifiedActionOf<CardFeature>)
        case details(PresentationAction<DetailsFeature.Action>)
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case topRated = "Top Rated"
        case onTheAir = "On the Air"
        case popular = "Popular"

        var id: String { rawValue }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .sortOptionChanged(option):
                state.selectedSort = option
                state.tvShowCards = []
                state.currentPage = 1
                state.hasMorePages = true
                return .send(.loadTVShows)

            case .onAppear:
                guard state.tvShowCards.isEmpty else { return .none }
                return .send(.loadTVShows)

            case .loadTVShows:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                let page = state.currentPage
                let sortOption = state.selectedSort

                return .run {@MainActor [tmdbClient] send in
                    do {
                        let response: TMDBResponse<TVShow>
                        switch sortOption {
                        case .topRated:
                            response = try await tmdbClient.fetchTopRatedTVShows(page)
                        case .onTheAir:
                            response = try await tmdbClient.fetchOnTheAirTVShows(page)
                        case .popular:
                            response = try await tmdbClient.fetchPopularTVShows(page)
                        }
                        send(.tvShowsLoaded(response))
                    } catch {
                        print("Error fetching TV shows: \(error)")
                    }
                }

            case .loadMoreTVShows:
                guard state.hasMorePages && !state.isLoading else { return .none }
                state.currentPage += 1
                return .send(.loadTVShows)

            case let .tvShowsLoaded(response):
                state.isLoading = false
                state.hasMorePages = response.page < response.totalPages

                let newCards = response.results.map { tvShow in
                    CardFeature.State(
                        id: tvShow.id,
                        title: tvShow.name,
                        coverImagePath: tvShow.posterPath ?? "",
                        overview: tvShow.overview,
                        rating: tvShow.voteAverage,
                        sizeClass: .medium,
                        mediaType: .tvShow
                    )
                }
                state.tvShowCards.append(contentsOf: newCards)
                return .none

            case let .tvShowCards(.element(id: id, action: .openDetails)):
                guard let tvShow = state.tvShowCards[id: id] else { return .none }
                state.details = DetailsFeature.State(
                    id: tvShow.id,
                    mediaType: .tvShow,
                    title: tvShow.title,
                    posterPath: tvShow.coverImagePath,
                    rating: tvShow.rating,
                    overview: tvShow.overview
                )
                return .none

            case .tvShowCards:
                return .none

            case .details(.presented(.dismiss)):
                state.details = nil
                return .none

            case .details:
                return .none
            }
        }
        .forEach(\.tvShowCards, action: \.tvShowCards) {
            CardFeature()
        }
        .ifLet(\.$details, action: \.details) {
            DetailsFeature()
        }
    }
}
