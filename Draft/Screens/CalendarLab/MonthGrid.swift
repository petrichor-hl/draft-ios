//
//  MonthGrid.swift
//  Draft
//

import SwiftUI

/// Lưới ngày của MỘT tháng.
///
/// Cố tình KHÔNG chứa tiêu đề tháng lẫn hàng weekday: hai thứ đó nằm ở màn hình
/// để chúng đứng yên trong khi các trang tháng trượt qua bên dưới.
///
/// Đây là toàn bộ phần dùng chung giữa bản iOS 16 và iOS 18 — hai bản chỉ khác
/// nhau ở cách phân trang, không khác ở cách vẽ một tháng.
struct MonthGrid: View {
  /// Ngày 1 của tháng, lúc 00:00:00. Bên gọi lo việc chuẩn hoá
  /// (dùng `MonthCalendar.startOfMonth(for:)`).
  let month: Date

  // 28/29/30/31 — Calendar tự biết năm nhuận, đừng tự tra bảng
  private var daysInMonth: Int {
    MonthCalendar.calendar.range(of: .day, in: .month, for: month)!.count
  }

  /// "Số ô trống trước ngày 1", hay "ngày 1 nằm ở cột thứ mấy (đếm từ 0)".
  /// +7 trước khi % 7 vì Swift giữ dấu của số bị chia: -1 % 7 == -1, không phải 6.
  private var leadingBlanks: Int {
    let calendar = MonthCalendar.calendar
    // weekday là địa chỉ tuyệt đối của ngày 1. Cố định: CN=1, T2=2, … T7=7
    let weekday = calendar.component(.weekday, from: month)
    return (weekday - calendar.firstWeekday + 7) % 7
  }

  private func isToday(_ day: Int) -> Bool {
    let calendar = MonthCalendar.calendar
    // day - 1 vì month đã là ngày 1 rồi
    let date = calendar.date(byAdding: .day, value: day - 1, to: month)!
    return calendar.isDate(date, inSameDayAs: Date())
  }

  var body: some View {
    LazyVGrid(columns: MonthCalendar.columns) {
      ForEach(0..<(leadingBlanks + daysInMonth), id: \.self) { index in
        if index < leadingBlanks {
          // Ô trống phải TỒN TẠI, không được bỏ qua bằng if:
          // LazyVGrid xếp theo thứ tự phần tử, thiếu một ô là cả tháng dịch trái.
          Color.clear
            .frame(maxWidth: .infinity, minHeight: 44)
        } else {
          let day = index - leadingBlanks + 1
          Text("\(day)")
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
              if isToday(day) {
                Circle().fill(.orange.opacity(0.35))
              }
            }
        }
      }
    }
  }
}

#Preview("Tháng hiện tại") {
  MonthGrid(month: MonthCalendar.startOfMonth(for: Date()))
}

#Preview("Aug 2026 — 6 hàng") {
  MonthGrid(month: MonthCalendar.calendar.date(from: DateComponents(year: 2026, month: 8))!)
}

#Preview("Feb 2021 — 4 hàng") {
  MonthGrid(month: MonthCalendar.calendar.date(from: DateComponents(year: 2021, month: 2))!)
}
