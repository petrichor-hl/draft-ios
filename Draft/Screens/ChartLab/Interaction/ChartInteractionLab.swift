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
        coordinator.push(.chartStepsSelection)
      } label: {
        ChartLabRow(title: "Apple Health — Steps",
                    subtitle: "chartXSelection + chartOverlay, chạm hoặc nhấn giữ để chọn")
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
