//
//  ColumnChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — cột dọc: BarMark(x: category, y: value).
//    .cornerRadius            bo đầu cột
//    width: .fixed / .ratio   bề rộng cột, thay vì để Charts tự tính
//    .position(by:)           tách nhóm nằm cạnh nhau (grouped)
//    nhiều BarMark cùng x      xếp chồng lên nhau (stacked) — mặc định
//
//  Column và Bar là CÙNG MỘT BarMark; khác nhau duy nhất ở chỗ category
//  nằm ở trục X hay trục Y. So sánh với BarChartScreen.
//

import Charts
import SwiftUI

struct ColumnChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.bar.fill")
      .navigationTitle("Column")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ColumnChartScreen()
  }
}
