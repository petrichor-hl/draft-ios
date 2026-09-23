//
//  BarChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — thanh ngang: BarMark(x: value, y: category). Đảo đúng hai
//  tham số so với ColumnChartScreen, không đổi gì khác.
//
//  Khi nào chọn ngang: nhãn category dài (tên món ăn, tên tỉnh) — để dọc
//  thì nhãn trục X bị xoay nghiêng hoặc cắt cụt. Số lượng hạng mục nhiều
//  cũng hợp với ngang vì cuộn dọc tự nhiên hơn cuộn ngang.
//

import Charts
import SwiftUI

struct BarChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.bar")
      .navigationTitle("Bar ngang")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    BarChartScreen()
  }
}
