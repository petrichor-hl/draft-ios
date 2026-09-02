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

  // Phép tính tháng nằm ở MonthCalendar vì màn hình cũng cần chúng
  // để tính chiều cao thẻ — không còn là chuyện riêng của lưới nữa.
  private var daysInMonth: Int { MonthCalendar.daysInMonth(of: month) }
  private var leadingBlanks: Int { MonthCalendar.leadingBlanks(of: month) }

  private func isToday(_ day: Int) -> Bool {
    let calendar = MonthCalendar.calendar
    // day - 1 vì month đã là ngày 1 rồi
    let date = calendar.date(byAdding: .day, value: day - 1, to: month)!
    return calendar.isDate(date, inSameDayAs: Date())
  }

  var body: some View {
    LazyVGrid(columns: MonthCalendar.columns, spacing: MonthCalendar.rowSpacing) {
      ForEach(0..<(leadingBlanks + daysInMonth), id: \.self) { index in
        if index < leadingBlanks {
          // Ô trống phải TỒN TẠI, không được bỏ qua bằng if:
          // LazyVGrid xếp theo thứ tự phần tử, thiếu một ô là cả tháng dịch trái.
          Color.clear
            .frame(maxWidth: .infinity, minHeight: MonthCalendar.cellHeight)
        } else {
          let day = index - leadingBlanks + 1
          Text("\(day)")
            .frame(maxWidth: .infinity, minHeight: MonthCalendar.cellHeight)
            .background {
              if isToday(day) {
                Circle().fill(.orange.opacity(0.35))
              }
            }
        }
      }
    }
    // Không đặt .frame chiều cao ở đây: để lưới giữ kích thước TỰ NHIÊN của nó.
    // Đề nghị cho nó một khung thấp hơn thì LazyVGrid sẽ nén hàng lại cho vừa,
    // và hàng của tháng 6 hàng sẽ không thẳng với tháng 5 hàng lúc lật trang.
    // Việc khoá/cắt là của bên phân trang.
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
