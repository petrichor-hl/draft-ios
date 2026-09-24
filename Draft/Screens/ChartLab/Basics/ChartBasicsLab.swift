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
      Section {
        Button {
          coordinator.push(.chartAnatomy)
        } label: {
          ChartLabRow(title: "1. Giải phẫu một Chart", subtitle: "Một mảng, ba loại Mark, không modifier nào")
        }

        Button {
          coordinator.push(.chartDataTypeAxis)
        } label: {
          ChartLabRow(title: "2. Kiểu dữ liệu → loại trục", subtitle: "String, Int, Date trên cùng trục X cho ba biểu đồ khác nhau")
        }

        Button {
          coordinator.push(.chartModifierLayers)
        } label: {
          ChartLabRow(title: "3. Modifier hai tầng", subtitle: "Trên mark vs trên chart — đặt nhầm tầng là sai chỗ")
        }

        Button {
          coordinator.push(.chartByScale)
        } label: {
          ChartLabRow(title: "4. `by:` và scale", subtitle: "Màu theo nhóm, stacked vs grouped, legend từ đâu ra")
        }

        Button {
          coordinator.push(.chartAxisCustom)
        } label: {
          ChartLabRow(title: "5. Trục tay", subtitle: "chartYScale cắt gốc 0, AxisMarks chọn mốc và định dạng nhãn")
        }

        Button {
          coordinator.push(.chartAnnotation)
        } label: {
          ChartLabRow(title: "6. Annotation", subtitle: "Cửa thoát duy nhất để đưa View vào trong Chart")
        }

        Button {
          coordinator.push(.chartBackgroundRegion)
        } label: {
          ChartLabRow(title: "7. Vùng nền", subtitle: "RectangleMark làm dải mục tiêu, vùng cảnh báo")
        }

        Button {
          coordinator.push(.chartRuleMark)
        } label: {
          ChartLabRow(title: "8. RuleMark", subtitle: "Đường trung bình, ngưỡng, mốc thời gian")
        }
      }
    }
    .navigationTitle("Basics")
  }
}

#Preview {
  NavigationStack {
    ChartBasicsLab()
      .environment(AppCoordinator())
  }
}
