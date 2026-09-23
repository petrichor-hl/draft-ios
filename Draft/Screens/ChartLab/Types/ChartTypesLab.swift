//
//  ChartTypesLab.swift
//  Draft
//
//  Nhóm 2 — từng loại chart một.
//

import SwiftUI

struct ChartTypesLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("BarMark") {
        Button {
          coordinator.push(.chartColumn)
        } label: {
          ChartLabRow(title: "1. Column",
                      subtitle: "Cột dọc: category ở trục X, stacked vs grouped")
        }

        Button {
          coordinator.push(.chartBar)
        } label: {
          ChartLabRow(title: "2. Bar ngang",
                      subtitle: "Đảo hai tham số — khi nhãn dài thì phải nằm ngang")
        }

        Button {
          coordinator.push(.chartRange)
        } label: {
          ChartLabRow(title: "3. Range",
                      subtitle: "yStart…yEnd — nền móng của chart Apple Health")
        }
      }

      Section("Đường và vùng") {
        Button {
          coordinator.push(.chartLine)
        } label: {
          ChartLabRow(title: "4. Line",
                      subtitle: "interpolationMethod, nét đứt, tách segment khi khuyết dữ liệu")
        }

        Button {
          coordinator.push(.chartArea)
        } label: {
          ChartLabRow(title: "5. Area",
                      subtitle: "Gradient xuống đáy, dải min–max, stacked area")
        }
      }

      Section("Còn lại") {
        Button {
          coordinator.push(.chartPoint)
        } label: {
          ChartLabRow(title: "6. Point / Scatter",
                      subtitle: "Hai trục đều liên tục — symbol và symbolSize theo nhóm")
        }

        Button {
          coordinator.push(.chartPieDonut)
        } label: {
          ChartLabRow(title: "7. Pie / Donut",
                      subtitle: "SectorMark — mark duy nhất dùng toạ độ cực")
        }

        Button {
          coordinator.push(.chartHeatmap)
        } label: {
          ChartLabRow(title: "8. Heatmap",
                      subtitle: "RectangleMark + color scale liên tục")
        }
      }
    }
    .navigationTitle("Các loại chart")
  }
}

#Preview {
  NavigationStack {
    ChartTypesLab()
      .environment(AppCoordinator())
  }
}
