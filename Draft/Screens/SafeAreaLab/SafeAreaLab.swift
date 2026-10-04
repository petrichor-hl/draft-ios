//
//  SafeAreaLab.swift
//  Draft
//

import SwiftUI

struct SafeAreaLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Section("Safe area") {
                Button {
                    coordinator.push(.safeAreaPadding)
                } label: {
                    labRow("safeAreaPadding", subtitle: "EdgeInsets hoặc edges + length")
                }

                Button {
                    coordinator.push(.safeAreaInsetLab)
                } label: {
                    labRow("safeAreaInset", subtitle: "Dynamic height, keyboard")
                }

                Button {
                    coordinator.push(.safeAreaBar)
                } label: {
                    labRow("safeAreaBar", subtitle: "edge, alignment, spacing, content")
                }

                Button {
                    coordinator.push(.ignoresSafeArea)
                } label: {
                    labRow("ignoresSafeArea", subtitle: "regions, edges — và overload có alignment")
                }
            }

            Section("Background & Overlay") {
                Button {
                    coordinator.push(.safeAreaBackground)
                } label: {
                    labRow("background", subtitle: "ignoresSafeAreaEdges — có hoặc không có style")
                }

                Button {
                    coordinator.push(.safeAreaOverlay)
                } label: {
                    labRow("overlay", subtitle: "style + ignoresSafeAreaEdges")
                }
            }

        }
        .navigationTitle("Safe Area Lab")
    }

    private func labRow(_ title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SafeAreaLab()
            .environment(AppCoordinator())
    }
}
