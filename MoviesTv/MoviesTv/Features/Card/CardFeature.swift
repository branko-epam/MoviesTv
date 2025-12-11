import ComposableArchitecture
import Foundation

@Reducer
struct CardFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: Int
        let title: String
        let coverImagePath: String
        let overview: String
        let rating: Double
        let sizeClass: SizeClass
        let mediaType: MediaType
        var coverUrl: URL? {
            guard let baseUrl = Bundle.main.infoDictionary?["MDB_IMG_URL"] as? String else {
                return nil
            }
            return URL(string: baseUrl + coverImagePath)
        }
    }

    enum MediaType: Equatable {
        case movie
        case tvShow
    }

    enum SizeClass: Equatable {
        case medium
        case large

        var width: CGFloat {
            switch self {
            case .medium: return 150
            case .large: return 200
            }
        }

        var height: CGFloat {
            width * 1.5
        }
    }

    enum Action {
        case openDetails(id: Int)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openDetails:
                return .none
            }
        }
    }
}
