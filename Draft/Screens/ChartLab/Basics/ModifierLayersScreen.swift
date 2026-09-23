//
//  ModifierLayersScreen.swift
//  Draft
//
//  ĐỀ BÀI — modifier của Swift Charts có hai tầng, đặt nhầm tầng là sai chỗ:
//    trên MARK  (bên trong Chart { })  — foregroundStyle, annotation,
//                                        interpolationMethod, lineStyle, opacity
//    trên CHART (bên ngoài Chart { })  — chartXAxis, chartLegend, chartYScale,
//                                        chartPlotStyle, chartBackground
//
//  Dựng cặp đối chứng: cùng một modifier đặt ở hai tầng, xem cái nào
//  áp lên một mark và cái nào áp lên cả biểu đồ.
//

import Charts
import SwiftUI

struct ModifierLayersScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "square.stack.3d.up")
      .navigationTitle("Modifier hai tầng")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ModifierLayersScreen()
  }
}
