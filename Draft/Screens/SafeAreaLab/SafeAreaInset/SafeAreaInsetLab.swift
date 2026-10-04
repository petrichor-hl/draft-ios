//
//  SafeAreaInsetLab.swift
//  Draft
//
//  Các use case của .safeAreaInset.

import SwiftUI

struct SafeAreaInsetLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.safeAreaInsetDynamicHeight)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dynamic height")
                        .font(.headline)
                    Text("Chạm thanh để đổi chiều cao 70 ↔ 200pt bằng animation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Button {
                coordinator.push(.safeAreaInsetKeyboard)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keyboard")
                        .font(.headline)
                    Text("Hiện bàn phím để quan sát thanh đáy và List")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(".safeAreaInset")
    }
}
