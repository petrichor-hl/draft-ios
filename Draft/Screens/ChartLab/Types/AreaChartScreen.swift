//
//  AreaChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — AreaMark: LineMark có tô phần dưới đường.
//    .foregroundStyle(LinearGradient)  gradient mờ dần xuống đáy
//    AreaMark(yStart:yEnd:)            dải giữa hai đường (min–max)
//    nhiều AreaMark cùng x             xếp chồng (stacked area)
//
//  Area luôn cần một mốc gốc để tô tới, nên nó nhạy với .chartYScale hơn
//  Line: cắt gốc trục thì phần tô cũng bị cắt theo.
//

import Charts
import SwiftUI

struct AreaChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.xyaxis.line")
      .navigationTitle("Area")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AreaChartScreen()
  }
}
