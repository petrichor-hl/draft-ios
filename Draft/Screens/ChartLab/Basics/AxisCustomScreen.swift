//
//  AxisCustomScreen.swift
//  Draft
//
//  ĐỀ BÀI — giành lại quyền điều khiển trục từ tay Charts:
//    .chartYScale(domain:)   cắt gốc 0 (Garmin để trục nhịp tim 62…190)
//    .chartXAxis / .chartYAxis + AxisMarks(values:)  chọn mốc hiển thị
//    AxisValueLabel(format:)  định dạng nhãn, AxisGridLine / AxisTick  kẻ lưới
//    AxisMarks(position: .leading)  đổi trục Y sang trái
//
//  Đã đo ở màn 1: miền trục Y mặc định LUÔN gồm 0, bất kể loại Mark.
//  Đây là màn học cách nói khác đi.
//

import Charts
import SwiftUI

struct AxisCustomScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "chart.xyaxis.line")
      .navigationTitle("Trục tay")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AxisCustomScreen()
  }
}
