import Foundation
import ComposableArchitecture

@Reducer
struct KeyKeywordsFeature {
    @ObservableState
    struct State: Equatable {
        var keywords: [SearchKeyword] = []
        var selectedKeyword: SearchKeyword? = nil
    }
    
    enum Action: Equatable {
        case updateKeywords([SearchKeyword])
        case didSelectKeyword(SearchKeyword)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateKeywords(let newKeywords):
                state.keywords = newKeywords
                return .none
            case .didSelectKeyword(let keyword):
                state.selectedKeyword = keyword
                return .none
            }
        }
    }
}
