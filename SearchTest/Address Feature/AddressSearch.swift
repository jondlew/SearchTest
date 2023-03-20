import Foundation
import Combine
import MapKit
import ComposableArchitecture
import Dependencies
import SwiftUI

public struct AddressSearch: Reducer {
    public init() {}
    
    public struct State: Equatable {
        var completions: [LocalSearchCompletion] = []
        var mapItems: [MKMapItem] = []
        var query = ""
        var searchResults: [MKPlacemark] = []
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case completionsUpdated(Result<[LocalSearchCompletion], NSError>)
        case onAppear
        case queryChanged(String)
        case searchResponse(TaskResult<LocalSearchClient.Response>)
        case tappedCompletion(LocalSearchCompletion)
    }
    @Dependency(\.localSearchCompleter) var localSearchCompleter
    @Dependency(\.localSearch) var localSearch
    @Dependency(\.dismiss) var dismiss
    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
        
            case let .completionsUpdated(.success(completions)):
                state.completions = completions
                return .none
           
            case let .completionsUpdated(.failure(error)):
                print(error)
                return .none
           
            case .onAppear:
               return localSearchCompleter.completions()
                    .map { $0.mapError { $0 as NSError } }
                    .map(Action.completionsUpdated)
                
            case let .queryChanged(query):
                state.query = query
                
                
                return localSearchCompleter.search(query).fireAndForget()
            
            
            case .searchResponse(.success(_)):
               
                return .fireAndForget {
                    await self.dismiss()
                }
           
            case let .searchResponse(.failure(error)):
                print(error)
                return .none
                
            case let .tappedCompletion(completion):
                state.query = completion.title
                return .task {
                    await .searchResponse( TaskResult { try await localSearch.search(completion)
                        
                    })
                }
            }
        }
    }
}

public struct AddressSearchView: View {
    let store: StoreOf<AddressSearch>
   
    
    public init(store: StoreOf<AddressSearch>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) {
            viewStore in
            
            NavigationView {
                List {
                    Section {
                        ForEach(viewStore.completions) { completion in
                            Button(action: {
                                viewStore.send(.tappedCompletion(completion))
                            }) {
                                VStack(alignment: .leading) {
                                    Text(completion.title)
                                    Text(completion.subtitle)
                                        .font(.caption)
                                }
                                
                            }
                        }
                    }
                    
                    
                }.listStyle(.automatic)
                .searchable(
                    text: viewStore.binding(
                      get: \.query,
                      send: AddressSearch.Action.queryChanged
                    ), prompt: Text("Address or Place Name"))
                
            }.onAppear {
                viewStore.send(.onAppear)
            }
            .navigationViewStyle(.stack)
        }
    }
}


struct AddressSearchView_Previews: PreviewProvider {
  static var previews: some View {
 
      AddressSearchView(
        store: Store(
            initialState: AddressSearch.State(),
          reducer: AddressSearch()
        )
      )
  }
}
