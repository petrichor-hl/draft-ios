//
//  GeneratorScreen.swift
//  Draft
//
//  Bước 3 — tầng UIKit: UIFeedbackGenerator.
//
//  Màn này chỉ là menu. Mỗi thí nghiệm nằm ở một screen riêng để
//  cảm nhận không bị nhiễu bởi các cú rung của section bên cạnh.
//

import SwiftUI

struct GeneratorScreen: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section {
        Button {
          coordinator.push(.hapticsPrepare)
        } label: {
          HapticLabRow(
            title: "A. prepare() & độ trễ ⭐️",
            subtitle: "Đo độ trễ Taptic Engine bằng ngón tay"
          )
        }

        Button {
          coordinator.push(.hapticsImpact)
        } label: {
          HapticLabRow(
            title: "B. Impact",
            subtitle: "5 style + intensity — style chốt ở init"
          )
        }

        Button {
          coordinator.push(.hapticsNotification)
        } label: {
          HapticLabRow(
            title: "C. Notification",
            subtitle: "3 loại — kéo dài, có tiết tấu, dễ chồng nhau"
          )
        }

        Button {
          coordinator.push(.hapticsSelection)
        } label: {
          HapticLabRow(
            title: "D. Selection",
            subtitle: "Chỉ có nghĩa khi bắn liên tục"
          )
        }

        Button {
          coordinator.push(.hapticsLocation)
        } label: {
          HapticLabRow(
            title: "E. Định vị (iOS 17.5+)",
            subtitle: "impactOccurred(at:) + UICanvasFeedbackGenerator"
          )
        }

        Button {
          coordinator.push(.hapticsOutsideView)
        } label: {
          HapticLabRow(
            title: "F. Bắn ngoài view",
            subtitle: "Haptic từ Task async — chỗ modifier bó tay"
          )
        }
      } footer: {
        Text("Cả 4 màn đều gọi thẳng UIKit, không dùng .sensoryFeedback. Mọi generator đều là @MainActor.")
      }
    }
    .navigationTitle("Generator")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    GeneratorScreen()
      .environment(AppCoordinator())
  }
}
