//
//  MonthCalendar.swift
//  Draft
//

import SwiftUI

/// Phần dùng chung cho cả hai màn Calendar (iOS 16 và iOS 18).
/// Để `static` vì đây là hằng số cấu hình, không phải state của view —
/// và vì `@State private var selectedMonth = ...` cần đọc được lúc khởi tạo,
/// mà lúc đó chưa có `self` để đọc property của instance.
enum MonthCalendar {
  static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)

    calendar.locale = .autoupdatingCurrent
    // tên thứ trong tuần theo ngôn ngữ người dùng
    // .autoupdatingCurrent là proxy sống — tự bám theo cài đặt hiện tại.

    // Cố tình không set `calendar.firstWeekday`, để nó theo:
    // Settings > Language & Region > First Day of Week (mặc định lấy theo Region)

    return calendar
  }()

  static let columns = Array(
    repeating: GridItem(.flexible(), spacing: 0),
    count: 7
  )

  static let cellHeight: CGFloat = 44
  static let rowSpacing: CGFloat = 8

  // 28/29/30/31 — Calendar tự biết năm nhuận, đừng tự tra bảng
  static func daysInMonth(of month: Date) -> Int {
    calendar.range(of: .day, in: .month, for: month)!.count
  }

  /// "Số ô trống trước ngày 1", hay "ngày 1 nằm ở cột thứ mấy (đếm từ 0)".
  /// +7 trước khi % 7 vì Swift giữ dấu của số bị chia: -1 % 7 == -1, không phải 6.
  static func leadingBlanks(of month: Date) -> Int {
    // weekday là địa chỉ tuyệt đối của ngày 1. Cố định: CN=1, T2=2, … T7=7
    let weekday = calendar.component(.weekday, from: month)
    return (weekday - calendar.firstWeekday + 7) % 7
  }

  /// Số hàng của tháng, luôn nằm trong 4...6.
  /// 4 chỉ xảy ra với tháng 2 năm không nhuận mà ngày 1 rơi đúng đầu tuần (VD 2/2021).
  static func rowCount(of month: Date) -> Int {
    let cells = leadingBlanks(of: month) + daysInMonth(of: month)
    // (x + 6) / 7 là phép chia làm tròn LÊN bằng số nguyên, khỏi qua Double và ceil.
    return (cells + 6) / 7
  }

  /// Chiều cao lưới của ĐÚNG tháng đó — nền tảng để thẻ co giãn theo tháng.
  ///
  /// Tính được mà không cần GeometryReader: biết tháng thì biết số hàng,
  /// biết số hàng thì ra chiều cao. Đo bằng layout chỉ tổ trễ một nhịp render.
  ///
  /// rowSpacing phải tự đặt (xem trên): spacing dọc mặc định của LazyVGrid không
  /// có con số cam kết trong tài liệu, không tính ra chiều cao chắc chắn được.
  static func gridHeight(of month: Date) -> CGFloat {
    let rows = CGFloat(rowCount(of: month))
    return cellHeight * rows + rowSpacing * (rows - 1)
  }

  /// Chiều cao của tháng NHIỀU HÀNG NHẤT (6) — kích thước thật của mỗi TRANG.
  ///
  /// Mọi trang phải cao bằng nhau, nếu không hai chuyện xảy ra khi lật:
  ///   1. Trang 6 hàng bị đề nghị khung 5 hàng thì LazyVGrid NÉN hàng cho vừa,
  ///      hàng của hai trang cao khác nhau nên không thẳng nhau.
  ///   2. Trang thấp hơn bị LazyHStack căn giữa dọc, lại lệch tiếp.
  /// Khung ngoài mới là thứ co giãn theo tháng, còn trang thì luôn 6 hàng.
  static let maxGridHeight = cellHeight * 6 + rowSpacing * 5

  // veryShortWeekdaySymbols luôn bắt đầu từ Chủ nhật, xoay lại cho khớp firstWeekday
  static var weekdaySymbols: [String] {
    let symbols = calendar.veryShortWeekdaySymbols
    return (0..<7).map { symbols[($0 + calendar.firstWeekday - 1) % 7] }
  }

  /// Ngày 1 của tháng chứa `date`, lúc 00:00:00.
  ///
  /// Bóc ra chỉ [.year, .month], cố tình vứt .day/.hour/.minute/.second.
  /// Khi ráp ngược, thành phần nào thiếu sẽ được điền giá trị nhỏ nhất
  /// => luôn ra ngày 1, lúc 00:00:00.
  ///
  /// Nên nó vừa là "lấy ngày 1", vừa là CHUẨN HOÁ — cắt sạch phần giờ/phút/giây.
  /// Chuẩn hoá là bắt buộc khi phân trang: `selectedMonth` phải khớp TUYỆT ĐỐI
  /// với một phần tử của `recentMonths` thì paging mới nhận ra trang nào đang mở.
  static func startOfMonth(for date: Date) -> Date {
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
  }

  /// 12 tháng gần nhất, cũ nhất trước. Mỗi phần tử là ngày 1 lúc 00:00:00.
  ///
  /// Đây LÀ giới hạn 12 tháng — không dựng trang nào ngoài mảng này,
  /// nên không cần kiểm tra biên ở chỗ nào khác nữa.
  /// Khoảng -11...0 chứ không phải -12...0: cửa sổ tính cả tháng hiện tại.
  static let recentMonths: [Date] = {
    let thisMonth = startOfMonth(for: Date())
    return (-11...0).map { calendar.date(byAdding: .month, value: $0, to: thisMonth)! }
  }()
}
