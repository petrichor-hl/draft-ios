//
//  ChartTypesLab.swift
//  Draft
//
//  Nhóm 2 — từng loại chart một. Chưa có màn nào.
//

import SwiftUI

struct ChartTypesLab: View {
  var body: some View {
    ContentUnavailableView("Chưa có màn nào", systemImage: "chart.bar.xaxis")
      .navigationTitle("Các loại chart")
  }
}

#Preview {
  NavigationStack {
    ChartTypesLab()
  }
}
