//
//  SearchTestApp.swift
//  SearchTest
//
//  Created by Jonathan on 3/19/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct SearchTestApp: App {
    var body: some Scene {
        WindowGroup {
            
            ListView(store: Store(initialState: ListFeature.State(), reducer: ListFeature()) )
            
        }
    }
}
