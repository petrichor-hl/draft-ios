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

  /// Các ô của tháng: nil = ô trống đầu tháng, còn lại là số ngày.
  ///
  /// Dựng SẴN thành mảng thay vì để ForEach hỏi leadingBlanks/daysInMonth ở
  /// từng ô. Trước đây `index < leadingBlanks` chạy trong closure nên
  /// leadingBlanks — vốn là một phép Calendar — bị gọi lại hơn 40 lần MỖI FRAME,
  /// nhân với số trang LazyHStack đang dựng. Giờ chỉ 2 lần cho cả lưới.
  private var cells: [Int?] {
    let blanks = [Int?](repeating: nil, count: MonthCalendar.leadingBlanks(of: month))
    return blanks + (1...MonthCalendar.daysInMonth(of: month)).map { Optional($0) }
  }

  /// Ngày nào trong tháng này là hôm nay, nil nếu hôm nay không thuộc tháng.
  ///
  /// Thay cho isToday(day) gọi ở từng ô: hỏi Calendar MỘT lần cho cả lưới rồi
  /// so số nguyên, thay vì dựng Date + isDate(_:inSameDayAs:) cho từng ngày.
  private var todayDay: Int? {
    let calendar = MonthCalendar.calendar
    let now = Date()
    guard calendar.isDate(month, equalTo: now, toGranularity: .month) else { return nil }
    return calendar.component(.day, from: now)
  }

  var body: some View {
    // Đọc một lần rồi truyền vào closure. Để nguyên `todayDay` trong closure là
    // nó lại thành một phép Calendar cho mỗi ô.
    let todayDay = todayDay

    LazyVGrid(columns: MonthCalendar.columns, spacing: MonthCalendar.rowSpacing) {
      ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
        if let day {
          Text("\(day)")
            .foregroundStyle(day == todayDay ? Color.white : Color.primary)
            .frame(maxWidth: .infinity, minHeight: MonthCalendar.cellHeight)
            .background {
              if day == todayDay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                  .fill(.tint)
                  .frame(width: MonthCalendar.cellHeight, height: MonthCalendar.cellHeight)
              }
            }
        } else {
          // Ô trống phải TỒN TẠI, không được bỏ qua:
          // LazyVGrid xếp theo thứ tự phần tử, thiếu một ô là cả tháng dịch trái.
          Color.clear
            .frame(maxWidth: .infinity, minHeight: MonthCalendar.cellHeight)
        }
      }
    }
  }
}
