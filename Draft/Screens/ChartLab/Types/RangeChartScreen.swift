//
//  RangeChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — mark biểu diễn một KHOẢNG thay vì một điểm:
//    BarMark(x:yStart:yEnd:)   thanh nối min đến max
//    .clipShape(Capsule())     bo tròn hai đầu
//    RectangleMark(...)        vùng chữ nhật, dùng cho gantt hoặc vùng nền
//
//  Đây là nền móng trực tiếp của chart Apple Health trong Toolbox: mỗi
//  vạch hồng là khoảng dao động nhịp tim trong một bucket thời gian, không
//  phải một phép đo đơn lẻ.
//

import Charts
import SwiftUI

struct RangeChartScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "arrow.up.and.down")
      .navigationTitle("Range")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RangeChartScreen()
  }
}
