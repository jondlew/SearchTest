//
//  DetailFeature.swift
//  SearchTest
//
//  Created by Jonathan on 3/20/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public struct DetailFeature: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        var item: Item
        var addressFeature = AddressFeature.State(mapAddress: nil)
        @PresentationState var child: ChildFeature.State?
        
        public init(item: Item) {
            self.item = item
        }
    }
    
    public enum Action: Equatable {
        case showChildTapped
        case child(PresentationAction<ChildFeature.Action>)
        case addressFeature(AddressFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .showChildTapped:
                state.child = ChildFeature.State()
                return .none
            case .child:
                return .none
            case .addressFeature:
                return .none
            }
            
        }
        
        Scope(state: \.addressFeature, action: /Action.addressFeature) {
          AddressFeature()
        }
        
        .ifLet(\.$child, action: /Action.child) {
            ChildFeature()
        }
        
    }
}
