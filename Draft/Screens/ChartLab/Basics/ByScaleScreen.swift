//
//  ByScaleScreen.swift
//  Draft
//
//  ĐỀ BÀI — hậu tố `by:` biến một hằng số thành scale:
//    .foregroundStyle(.blue)                        → tô xanh cứng, không legend
//    .foregroundStyle(by: .value("Loại", item.kind)) → Charts tự gán màu + tự sinh legend
//
//  Kèm .position(by:) để thấy cùng một bộ dữ liệu ra stacked hay grouped bar,
//  và .symbol(by:) cho PointMark. Legend xuất hiện là do `by:`, không phải
//  do bật tắt ở đâu cả.
//

import Charts
import SwiftUI

struct ByScaleScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "paintpalette")
      .navigationTitle("`by:` và scale")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ByScaleScreen()
  }
}
