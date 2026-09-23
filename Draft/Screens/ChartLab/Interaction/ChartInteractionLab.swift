//
//  ChartInteractionLab.swift
//  Draft
//
//  Nhóm 3 — chạm, chọn, cuộn trên chart. Chưa có màn nào.
//

import SwiftUI

struct ChartInteractionLab: View {
  var body: some View {
    ContentUnavailableView("Chưa có màn nào", systemImage: "hand.tap")
      .navigationTitle("Tương tác")
  }
}

#Preview {
  NavigationStack {
    ChartInteractionLab()
  }
}
