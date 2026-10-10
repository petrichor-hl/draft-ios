//
//  MaskLab.swift
//  Draft
//

import SwiftUI

struct MaskLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.scrollableTabView)
            } label: {
                Text("Building Scrollable Tab View With New iOS 17 APIs")
            }
        }
        .navigationTitle(".mask Lab")
    }
}

#Preview {
    NavigationStack {
        MaskLab()
            .environment(AppCoordinator())
    }
}
