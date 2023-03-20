//
//  AppReducer.swift
//  SearchTest
//
//  Created by Jonathan on 3/19/23.
//

import Foundation
import ComposableArchitecture

public struct Item: Equatable, Identifiable {
    public let id = UUID()
    var name: String
}

public struct ListFeature: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
       // @PresentationState var addressFeature: AddressFeature.State?
        @PresentationState var detail: DetailFeature.State?
        var items:[Item] = [Item(name: "Thing 1"), Item(name: "Thing 2")]
        
    }
    
    public enum Action: Equatable {
//        case showAddressFeatureTapped
//        case showChildTapped
      //  case addressFeature(PresentationAction<AddressFeature.Action>)
        case detail(PresentationAction<DetailFeature.Action>)
        case itemTapped(Item)
    
    }
    
    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
//            case .showAddressFeatureTapped:
//                state.addressFeature = AddressFeature.State(mapAddress: nil)
//                return .none
//
//            case .showChildTapped:
//                state.child = Child.State()
//                return .none
                
            case .itemTapped(let item):
                state.detail = DetailFeature.State(item: item)
                return .none
                
//            case .addressFeature:
//                return .none
                
            case .detail:
                return .none
            }
        }
    
        
        .ifLet(\.$detail, action: /Action.detail) {
            DetailFeature()
        }
    }
}

