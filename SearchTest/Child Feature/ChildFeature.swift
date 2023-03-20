//
//  ChildReducer.swift
//  SearchTest
//
//  Created by Jonathan on 3/19/23.
//

import Foundation
import ComposableArchitecture

public struct ChildFeature: Reducer {
    public init() {}
    
    public struct State: Equatable {
        var addressFeature = AddressFeature.State(mapAddress: nil)
    }
    
    public enum Action: Equatable {
        case addressFeature(AddressFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
                
        Reduce { state, action in
            switch action {

            case .addressFeature:
                return .none
            }
        }
        
        Scope(state: \.addressFeature, action: /Action.addressFeature) {
          AddressFeature()
        }
    }
}
