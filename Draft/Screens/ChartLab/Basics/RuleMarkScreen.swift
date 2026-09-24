//
//  RuleMarkScreen.swift
//  Draft
//
//  ĐỀ BÀI — RuleMark là mark KHÔNG thuộc về điểm dữ liệu nào. Mọi mark khác
//  sinh ra từ một phần tử trong mảng; RuleMark là đường tham chiếu của cả
//  biểu đồ: đường trung bình, ngưỡng cảnh báo, mốc thời gian đáng chú ý.
//
//    RuleMark(y:)                 đường ngang suốt chiều rộng
//    RuleMark(x:)                 đường dọc suốt chiều cao
//    RuleMark(xStart:xEnd:y:)     đoạn ngang chỉ trong một khoảng
//    RectangleMark(yStart:yEnd:)  cả một VÙNG thay vì một đường
//
//  Vì không thuộc phần tử nào nên phải viết ngoài ForEach — bắt buộc dùng
//  dạng Chart { } thay vì Chart(data) { }, như đã gặp ở màn 3 section E.
//
//  CẦN ĐO: RuleMark có được tính vào domain trục Y không? Nếu có thì đặt
//  một ngưỡng 200.000 sẽ bóp bẹp toàn bộ biểu đồ xuống đáy khung.
//

import Charts
import SwiftUI

struct RuleMarkScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "ruler")
      .navigationTitle("RuleMark & vùng nền")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RuleMarkScreen()
  }
}
