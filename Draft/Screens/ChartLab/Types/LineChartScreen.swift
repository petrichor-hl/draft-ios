//
//  LineChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — LineMark:
//    .interpolationMethod(.catmullRom / .monotone / .stepEnd)  dáng đường
//    .lineStyle(StrokeStyle(lineWidth:dash:))                  nét đứt
//    series: .value(...)                                       tách nhiều đường
//
//  Cái bẫy để dành cho Garmin: dữ liệu khuyết vài giờ thì LineMark NỐI
//  THẲNG qua khoảng trống, không tự đứt. Muốn đứt đoạn phải tách segment
//  bằng tham số series:. Dựng cặp đối chứng có/không tách để thấy rõ.
//

import Charts
import SwiftUI

struct LineChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.line.uptrend.xyaxis")
      .navigationTitle("Line")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    LineChartScreen()
  }
}
