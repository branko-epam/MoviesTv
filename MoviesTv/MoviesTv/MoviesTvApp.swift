//
//  MoviesTvApp.swift
//  MoviesTv
//
//  Created by Branko Popovic1 on 9. 12. 2025..
//

import SwiftUI
import ComposableArchitecture

@main
struct MoviesTvApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
