//
//  ChartBasicsLab.swift
//  Draft
//
//  Nhóm 1 — cơ chế nền của Swift Charts. Chưa có màn nào.
//

import SwiftUI

struct ChartBasicsLab: View {
  var body: some View {
    ContentUnavailableView("Chưa có màn nào", systemImage: "chart.xyaxis.line")
      .navigationTitle("Basics")
  }
}

#Preview {
  NavigationStack {
    ChartBasicsLab()
  }
}
