//
//  CalendarLab.swift
//  Draft
//
//  Menu các cách dựng lịch tháng có phân trang.
//
//  Cùng một giao diện, khác nhau ở cách lật tháng:
//    - iOS 16: TabView + .tabViewStyle(.page)  — có từ iOS 14
//    - iOS 18: ScrollView + .scrollTargetBehavior(.paging) — cần iOS 17+
//
//  Phần dùng chung nằm ở MonthCalendar.swift (cấu hình + phép tính tháng)
//  và MonthGrid.swift (vẽ một tháng).
//

import SwiftUI

struct CalendarLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("Phân trang tháng") {
        Button {
          coordinator.push(.calendar)
        } label: {
          row(
            title: "TabView .page (iOS 16)",
            subtitle: "Chạy từ iOS 14, nhưng bắt buộc .frame(height:)"
          )
        }

        Button {
          coordinator.push(.calendariOS18)
        } label: {
          row(
            title: "ScrollView .paging (iOS 18)",
            subtitle: "scrollTargetBehavior + scrollPosition, cần iOS 17+"
          )
        }
      }
    }
    .navigationTitle("Calendar Lab")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func row(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.body)

      Text(subtitle)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  NavigationStack {
    CalendarLab()
  }
}
