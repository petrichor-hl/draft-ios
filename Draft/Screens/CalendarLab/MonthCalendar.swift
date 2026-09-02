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
  static var recentMonths: [Date] {
    let thisMonth = startOfMonth(for: Date())
    return (-11...0).map { calendar.date(byAdding: .month, value: $0, to: thisMonth)! }
  }
}
