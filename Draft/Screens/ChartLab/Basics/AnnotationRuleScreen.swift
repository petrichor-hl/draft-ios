//
//  AnnotationRuleScreen.swift
//  Draft
//
//  ĐỀ BÀI — thêm chữ và đường kẻ vào chart:
//    .annotation(position:alignment:spacing:)  gắn nhãn lên đầu cột
//    RuleMark(y:)                              đường trung bình nằm ngang
//    RuleMark(x:)                              đường dọc đánh dấu một mốc
//    RectangleMark(yStart:yEnd:)               tô vùng nền (vd vùng nhịp tim mục tiêu)
//
//  Annotation là modifier của MARK, không phải của chart — đặt sai tầng
//  thì compile được nhưng gắn nhầm chỗ.
//

import Charts
import SwiftUI

struct AnnotationRuleScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "text.bubble")
      .navigationTitle("Annotation & RuleMark")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AnnotationRuleScreen()
  }
}
