//
//  DraftApp.swift
//  Draft
//
//  Created by Lam Tran  on 5/6/26.
//

import SwiftUI

@main
struct DraftApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var coordinator = AppCoordinator()
    
    @AppStorage(StorageKeys.appLanguage) private var language: AppLanguage = .vietnamese
    @AppStorage(StorageKeys.appAppearance) private var appearance: AppAppearance = .system
    
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
            .preferredColorScheme(appearance.colorScheme)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                SnackBarWindowManager.shared.setup()
                ToastWindowManager.shared.setup()
            }
        }
    }
}
