//
//  RaiseTheBar.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import SwiftUI

struct RaiseTheBar: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartLocationDetailsBarMark)
      } label: {
        ChartLabRow(title: "1. Location Details — BarMark",
                    subtitle: "Hai thành phố xếp chồng, foregroundStyle(by:) tách màu")
      }
    }
    .navigationTitle("Raise the bar")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RaiseTheBar()
      .environment(AppCoordinator())
  }
}
