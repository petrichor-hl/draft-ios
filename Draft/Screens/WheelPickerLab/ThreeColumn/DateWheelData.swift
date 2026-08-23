//
//  DateWheelData.swift
//  Draft
//
//  Miền dữ liệu của ca ngày/tháng/năm, dùng chung cho cả hai cách dựng.
//
//  Ở ca cân nặng, luật "chạm 200 thì phần lẻ về 0" được chép vào cả hai sheet.
//  Chép được vì nó là một dòng `if`. Ở đây thì không nên: luật là "tháng 2 năm
//  nhuận có 29 ngày", mà lịch thì không phải thứ nên viết hai lần rồi hy vọng
//  hai bản giống nhau. Sửa một bên quên bên kia là hai sheet cho hai kết quả
//  khác nhau mà vẫn build xanh.
//
//  Ranh giới giữ nguyên như cũ: view chỉ nhận mảng nhãn và index, không biết
//  ngày tháng là gì. File này là chỗ DUY NHẤT biết.
//

import Foundation

enum DateWheelData {
  /// Dải năm quanh năm hiện tại, không viết cứng — xem `BirthYearTableWheelSheet`.
  static var yearRange: ClosedRange<Int> {
    let now = Calendar.current.component(.year, from: Date())
    return (now - 5)...(now + 5)
  }

  static var years: [Int] { Array(yearRange) }

  static let months: [Int] = Array(1...12)

  /// Nhãn tháng theo mockup: "tháng 1", không phải "Tháng Một" hay "January".
  ///
  /// Ghép chuỗi thủ công chứ không qua `DateFormatter.monthSymbols`: kho này
  /// chạy dưới `.environment(\.locale, …)` đổi được từ màn Language Picker, và
  /// tên tháng bản địa hoá sẽ dài ngắn khác nhau làm vỡ bề rộng cột.
  static func monthLabel(_ month: Int) -> String { "tháng \(month)" }

  /// Số ngày của tháng — hỏi `Calendar` chứ không tự viết bảng 30/31 và luật
  /// năm nhuận. Luật nhuận không phải "chia hết cho 4": 1900 không nhuận,
  /// 2000 thì có.
  static func dayCount(month: Int, year: Int) -> Int {
    var components = DateComponents()
    components.year = year
    components.month = month
    let calendar = Calendar.current
    guard
      let date = calendar.date(from: components),
      let range = calendar.range(of: .day, in: .month, for: date)
    else {
      return 31
    }
    return range.count
  }

  /// Chỉ số ngày sau khi kẹp vào tháng/năm đang chọn.
  ///
  /// Trả về CHỈ SỐ chứ không phải ngày, để sheet gán thẳng vào `dayIndex` mà
  /// không phải cộng trừ 1 ở hai chỗ.
  static func clampedDayIndex(_ dayIndex: Int, month: Int, year: Int) -> Int {
    min(max(dayIndex, 0), dayCount(month: month, year: year) - 1)
  }
}

/// Giá trị canonical của ca này.
///
/// Ba `Int` rời chứ không phải `Date`: `Date` là một MỐC THỜI GIAN, nó kéo theo
/// giờ, phút, múi giờ — những thứ bánh xe không hỏi và người dùng không chọn.
/// Nhét 11/01/2026 vào `Date` là tự ép mình trả lời "lúc mấy giờ, ở múi nào",
/// rồi lãnh đủ khi so sánh hai ngày mà lệch nhau vài tiếng.
///
/// Cùng một lối nghĩ với `Int` phần mười kg ở ca cân nặng: canonical phải là
/// thứ vừa khít với cái người dùng thật sự chọn, không hơn.
struct WheelDate: Equatable {
  var day: Int
  var month: Int
  var year: Int

  /// Hiển thị theo mockup: "11 tháng 1, 2026".
  var text: String {
    "\(day) \(DateWheelData.monthLabel(month)), \(year)"
  }
}
