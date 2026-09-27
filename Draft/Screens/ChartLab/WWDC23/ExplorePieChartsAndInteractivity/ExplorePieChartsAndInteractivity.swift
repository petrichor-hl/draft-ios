//
//  ExplorePieChartsAndInteractivity.swift
//  Draft
//
//  Created by Lam Tran  on 27/9/26.
//

import SwiftUI

struct ExplorePieChartsAndInteractivity: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartExplorePieCharts)
      } label: {
        ChartLabRow(title: "1. Explore Pie Charts",
                    subtitle: "SectorMark và biểu đồ tròn")
      }

      Button {
        coordinator.push(.chartInteractivity)
      } label: {
        ChartLabRow(title: "2. Interactivity",
                    subtitle: "Tương tác với Swift Charts")
      }
    }
    .navigationTitle("Explore pie charts and interactivity")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ExplorePieChartsAndInteractivity()
      .environment(AppCoordinator())
  }
}
