//
//  HeatmapScreen.swift
//  Draft
//
//  ĐỀ BÀI — RectangleMark với hai trục category và màu mang giá trị:
//    RectangleMark(x: .value(...), y: .value(...))
//    .foregroundStyle(by: .value("Số", n))  → color scale liên tục
//    .chartForegroundStyleScale(range: Gradient(colors:))
//
//  Continuous color scale ở đây chính là kỹ thuật Garmin dùng để tô đường
//  nhịp tim đổi màu theo zone — học ở đây, dùng lại ở Toolbox.
//

import Charts
import SwiftUI

struct HeatmapScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "square.grid.3x3.fill")
      .navigationTitle("Heatmap")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    HeatmapScreen()
  }
}
