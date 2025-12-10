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
        var coverUrl: URL? {
            guard let baseUrl = Bundle.main.infoDictionary?["MDB_IMG_URL"] as? String else {
                return nil
            }
            return URL(string: baseUrl + coverImagePath)
        }
    }
    
    enum Action {
        case openDetails(id: Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openDetails(let id):
                return .none
            }
        }
    }
}
