//
//  HapticsLab.swift
//  Draft
//
//  Menu các cách tạo haptic feedback, đi từ API cao xuống thấp.
//  LƯU Ý: Simulator không có Taptic Engine — phải chạy trên iPhone thật.
//

import SwiftUI

struct HapticsLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section {
        Button {
          coordinator.push(.hapticsSensory)
        } label: {
          HapticLabRow(
            title: "1. SensoryFeedback ⭐️",
            subtitle: "SwiftUI iOS 17+ — khai báo theo state"
          )
        }

        Button {
          coordinator.push(.hapticsGenerator)
        } label: {
          HapticLabRow(
            title: "2. Feedback Generator",
            subtitle: "UIKit — prepare(), impact, notification, selection"
          )
        }

        Button {
          coordinator.push(.hapticsCore)
        } label: {
          HapticLabRow(
            title: "3. Core Haptics",
            subtitle: "Tự vẽ sóng: intensity × sharpness × duration"
          )
        }

        Button {
          coordinator.push(.hapticsRealWorld)
        } label: {
          HapticLabRow(
            title: "4. Real World",
            subtitle: "Picker, drag-snap, submit form"
          )
        }
      } footer: {
        Text("Haptic chỉ hoạt động trên iPhone thật. Simulator, iPad, Low Power Mode đều im lặng.")
      }
    }
    .navigationTitle("Haptics Lab")
  }
}

#Preview {
  NavigationStack {
    HapticsLab()
      .environment(AppCoordinator())
  }
}
