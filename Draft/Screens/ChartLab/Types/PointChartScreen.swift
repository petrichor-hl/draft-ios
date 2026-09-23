//
//  PointChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — PointMark, tức scatter plot:
//    .symbol(by:)      đổi hình dấu theo nhóm (tròn, vuông, tam giác)
//    .symbolSize(by:)  đổi cỡ dấu theo một chiều dữ liệu thứ ba → bubble chart
//    hai trục đều là số, không có category nào
//
//  Đây là loại chart duy nhất trong nhóm dùng được khi CẢ HAI trục đều
//  liên tục — dùng để xem tương quan chứ không phải so sánh hạng mục.
//

import Charts
import SwiftUI

struct PointChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.dots.scatter")
      .navigationTitle("Point / Scatter")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    PointChartScreen()
  }
}
