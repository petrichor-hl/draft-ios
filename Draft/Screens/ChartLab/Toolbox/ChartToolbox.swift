//
//  ChartToolbox.swift
//  Draft
//
//  Nhóm 4 — chart dựng lại từ app thật. Chưa có màn nào.
//

import SwiftUI

struct ChartToolbox: View {
  var body: some View {
    ContentUnavailableView("Chưa có màn nào", systemImage: "wrench.and.screwdriver")
      .navigationTitle("Toolbox")
  }
}

#Preview {
  NavigationStack {
    ChartToolbox()
  }
}
