//
//  PieDonutScreen.swift
//  Draft
//
//  ĐỀ BÀI — SectorMark (iOS 17+):
//    innerRadius: .ratio(0)      → pie đặc
//    innerRadius: .ratio(0.6)    → donut, chừa lỗ giữa
//    angularInset:               khe hở giữa các lát
//    .chartBackground            nhét tổng số vào giữa lỗ donut
//
//  SectorMark không có trục X/Y — nó là mark duy nhất trong lab dùng hệ
//  toạ độ cực, nên phần lớn modifier về trục không áp dụng được.
//

import Charts
import SwiftUI

struct PieDonutScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.pie")
      .navigationTitle("Pie / Donut")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    PieDonutScreen()
  }
}
