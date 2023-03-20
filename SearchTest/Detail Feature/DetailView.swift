//
//  DetailView.swift
//  SearchTest
//
//  Created by Jonathan on 3/20/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    public init(store: StoreOf<DetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                Section {
                    HStack {
                        Spacer()
                        
                        Button("Show Child") {
                            viewStore.send(.showChildTapped)
                        }.buttonStyle(.bordered)
                            .padding()
                        Spacer()
                    }
                    
                } header: {
                    Text("Address Feature Broken in Child")
                }
                Section {
                    AddressFeatureView(
                        store: self.store.scope(state: \.addressFeature, action: DetailFeature.Action.addressFeature)
                    )
                } header: {
                    Text("Address Feature Works Here")
                }
            }
            .padding()
            .navigationTitle("\(viewStore.state.item.name) Detail View")
            .sheet(store: store.scope(state: \.$child, action: DetailFeature.Action.child)) { store in NavigationView {
                ChildView(store: store)
            }
            }
        }
    }
}
