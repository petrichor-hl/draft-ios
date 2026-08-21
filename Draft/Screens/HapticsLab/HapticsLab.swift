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
          LabRow(title: "SensoryFeedback ⭐️",
                 subtitle: "SwiftUI iOS 17+ — khai báo theo state")
        }

        Button {
          coordinator.push(.hapticsGenerator)
        } label: {
          LabRow(title: "Feedback Generator",
                 subtitle: "UIKit — intensity + so sánh prepare()")
        }

        Button {
          coordinator.push(.hapticsCore)
        } label: {
          LabRow(title: "Core Haptics",
                 subtitle: "Tự vẽ sóng: intensity × sharpness × duration")
        }

        Button {
          coordinator.push(.hapticsRealWorld)
        } label: {
          LabRow(title: "Real World",
                 subtitle: "Picker, drag-snap, submit form")
        }
      } footer: {
        Text("Haptic chỉ hoạt động trên iPhone thật. Simulator, iPad, Low Power Mode đều im lặng.")
      }
    }
    .navigationTitle("Haptics Lab")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    HapticsLab()
      .environment(AppCoordinator())
  }
}
