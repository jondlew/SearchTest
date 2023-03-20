//
//  ContentView.swift
//  SearchTest
//
//  Created by Jonathan on 3/19/23.
//

import SwiftUI
import ComposableArchitecture




struct ListView: View {
    
    let store: StoreOf<ListFeature>
    
    public init(store: StoreOf<ListFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        ForEach(viewStore.items) { item in
                            Button {
                                viewStore.send(.itemTapped(item))
                            } label: {
                                Text(item.name)
                            }
                        }
                    } header: {
                        Text("Things")
                    }
                }
                .listStyle(.insetGrouped)
                .navigationDestination(
                    store: self.store.scope(state: \.$detail, action: ListFeature.Action.detail)) { store in
                        DetailView(store: store)
                        
                    }
                    .padding()
                    .navigationTitle("Test App")
            }
            
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView(store: Store(initialState: ListFeature.State(), reducer: ListFeature()))
//    }
//}
