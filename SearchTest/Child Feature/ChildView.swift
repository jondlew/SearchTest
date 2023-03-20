//
//  ChildView.swift
//  SearchTest
//
//  Created by Jonathan on 3/19/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ChildView: View {
    
    let store: StoreOf<ChildFeature>
    
    public init(store: StoreOf<ChildFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    Section {
                        Text("Address Lookup reloads view with each keystroke – search field loses focus!").multilineTextAlignment(.center)
                        AddressFeatureView(
                            store: self.store.scope(state: \.addressFeature, action: ChildFeature.Action.addressFeature)
                        )
                    }
                }
                .navigationTitle("Child Feature")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
        
        }
        
    }
}

struct ChildView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChildView(store: Store(initialState: ChildFeature.State(), reducer: ChildFeature()))
        }
    }
}

