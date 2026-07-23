//
//  DraftApp.swift
//  Draft
//
//  Created by Lam Tran  on 5/6/26.
//

import SwiftUI

@main
struct DraftApp: App {
    @State private var coordinator = AppCoordinator()

    @AppStorage(StorageKeys.appLanguage) private var language: AppLanguage = .vietnamese

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                AppendixView()
                    .navigationDestination(for: AppRoute.self) { route in
                        route
                    }
            }
            .environment(coordinator)
            .environment(\.locale, language.locale)
        }
    }
}
