//
//  ChartBasicsLab.swift
//  Draft
//
//  Nhóm 1 — cơ chế nền của Swift Charts.
//

import SwiftUI

struct ChartBasicsLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.chartAnatomy)
      } label: {
        LabRow(title: "1. Giải phẫu một Chart",
               subtitle: "Một mảng, một BarMark, không modifier nào")
      }
    }
    .navigationTitle("Basics")
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
    ChartBasicsLab()
      .environment(AppCoordinator())
  }
}
