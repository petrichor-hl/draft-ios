//
//  RuleMarkScreen.swift
//  Draft
//
//  ĐỀ BÀI — RuleMark vẽ một ĐƯỜNG tham chiếu cho cả biểu đồ: trung bình,
//  ngưỡng, mốc thời gian đáng chú ý. Như RectangleMark ở màn trước, nó
//  không thuộc về điểm dữ liệu nào nên phải viết ngoài ForEach.
//
//    RuleMark(y:)               đường ngang suốt chiều rộng
//    RuleMark(x:)               đường dọc suốt chiều cao
//    RuleMark(xStart:xEnd:y:)   đoạn ngang chỉ trong một khoảng
//    RuleMark(x:yStart:yEnd:)   đoạn dọc chỉ trong một khoảng
//
//  Kèm .lineStyle(StrokeStyle(dash:)) cho nét đứt và .annotation để gắn
//  nhãn cho chính đường đó.
//
//  CẦN ĐO:
//    1. RuleMark có ăn vào domain không? RectangleMark thì CÓ — đo ở màn
//       Vùng nền, vùng 15.000–20.000 kéo trục lên 20.000.
//    2. RuleMark(x:) trên band scale rơi vào TÂM dải hay MÉP dải? Vùng nền
//       đã cho thấy .value("Từ", "T3") trỏ vào tâm.
//    3. Gắn được annotation lên RuleMark không, và nhãn neo vào đâu?
//

import Charts
import SwiftUI

struct RuleMarkScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "ruler")
      .navigationTitle("RuleMark")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RuleMarkScreen()
  }
}
