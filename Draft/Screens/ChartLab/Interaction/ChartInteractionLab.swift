//
//  ChartInteractionLab.swift
//  Draft
//
//  Nhóm 3 — chạm, chọn, cuộn trên chart.
//

import SwiftUI

struct ChartInteractionLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartTapSelect)
      } label: {
        ChartLabRow(title: "1. Chạm chọn cột",
                    subtitle: "chartXSelection chỉ ăn chạm giữ — thử thêm tap bằng chartGesture")
      }
    }
    .navigationTitle("Tương tác")
  }
}

#Preview {
  NavigationStack {
    ChartInteractionLab()
      .environment(AppCoordinator())
  }
}
