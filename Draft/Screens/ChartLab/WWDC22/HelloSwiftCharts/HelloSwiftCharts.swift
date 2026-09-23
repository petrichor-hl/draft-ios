//
//  HelloSwiftCharts.swift | Youtube: https://www.youtube.com/watch?v=7rjM0cnEg7U
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import SwiftUI

struct HelloSwiftCharts: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartCupertinoDetails)
      } label: {
        ChartLabRow(title: "1. Cupertino Details",
                    subtitle: "BarMark bánh bán theo ngày — x là Date với unit: .day")
      }

      Button {
        coordinator.push(.chartLocationsToggle)
      } label: {
        ChartLabRow(title: "2. Locations Toggle",
                    subtitle: "Cupertino và San Francisco — bật tắt từng thành phố")
      }

      Button {
        coordinator.push(.chartLocationDetails)
      } label: {
        ChartLabRow(title: "3. Location Details",
                    subtitle: "Series gộp hai thành phố — foregroundStyle(by:) sinh legend")
      }
    }
    .navigationTitle("Hello Swift Charts")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    HelloSwiftCharts()
      .environment(AppCoordinator())
  }
}
