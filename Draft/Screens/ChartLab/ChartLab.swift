//
//  ChartLab.swift
//  Draft
//
//  Menu các nhóm thí nghiệm về Swift Charts: cơ chế nền, từng loại chart,
//  tương tác, và các chart dựng lại từ app thật.
//

import SwiftUI

struct ChartLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartBasics)
      } label: {
        LabRow(title: "1. Basics",
               subtitle: "Chart, Mark, PlottableValue — kiểu dữ liệu quyết định loại trục")
      }

      Button {
        coordinator.push(.chartTypes)
      } label: {
        LabRow(title: "2. Các loại chart",
               subtitle: "Column, Bar, Line, Area, Point, Pie, Range, Heatmap")
      }

      Button {
        coordinator.push(.chartInteraction)
      } label: {
        LabRow(title: "3. Tương tác",
               subtitle: "Chạm chọn điểm, cuộn ngang, snap từng trang")
      }

      Button {
        coordinator.push(.chartToolbox)
      } label: {
        LabRow(title: "4. Toolbox",
               subtitle: "Chart dựng lại từ app thật: Apple Health, Garmin Connect")
      }
    }
    .navigationTitle("Chart Lab")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    ChartLab()
      .environment(AppCoordinator())
  }
}
