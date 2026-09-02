//
//  CalendarScreen.swift
//  Draft
//

import SwiftUI

struct CalendarScreen: View {
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    
    calendar.locale = .autoupdatingCurrent
    // tên thứ trong tuần theo ngôn ngữ người dùng
    // .autoupdatingCurrent là proxy sống — tự bám theo cài đặt hiện tại.
    
    // Cố tình không set `calendar.firstWeekday`, để nó theo:
    // Settings > Language & Region > First Day of Week (mặc định lấy theo Region)

    return calendar
  }()

  let columns = Array(
    repeating: GridItem(.flexible(), spacing: 0),
    count: 7
  )

  // veryShortWeekdaySymbols luôn bắt đầu từ Chủ nhật, xoay lại cho khớp firstWeekday
  var weekdaySymbols: [String] {
    let symbols = calendar.veryShortWeekdaySymbols
    return (0..<7).map { symbols[($0 + calendar.firstWeekday - 1) % 7] }
  }


  // Single source of truth.
  // Tháng đang hiển thị. Đổi biến này là cả lịch tính lại theo.
  @State private var anchorDate = Date()

  // Ngày 1 của tháng chứa anchorDate — mọi phép tính bên dưới đều neo vào đây.
  //
  // Cách làm là vòng Date -> DateComponents -> Date:
  // bóc ra chỉ [.year, .month], cố tình vứt .day/.hour/.minute/.second.
  // Khi ráp ngược, thành phần nào thiếu sẽ được điền giá trị nhỏ nhất
  // => luôn ra ngày 1, lúc 00:00:00.
  //
  // Nên nó vừa là "lấy ngày 1", vừa là CHUẨN HOÁ — cắt sạch phần giờ/phút/giây.
  //
  // date(from:) trả Optional vì DateComponents có thể vô nghĩa (VD month = 13).
  // Ở đây components do chính Calendar vừa bóc ra nên chắc chắn hợp lệ -> ! an toàn.
  var firstDateOfMonth: Date {
    let components = calendar.dateComponents([.year, .month], from: anchorDate)
    return calendar.date(from: components)!
  }

  // 28/29/30/31 — Calendar tự biết năm nhuận, đừng tự tra bảng
  var daysInMonth: Int {
    calendar.range(of: .day, in: .month, for: firstDateOfMonth)!.count
  }

  // "Số ô trống trước ngày 1" hoặc "Ngày 1 của tháng này nằm ở cột thứ mấy (đếm từ 0)?"
  var leadingBlanks: Int {
    let weekday = calendar.component(.weekday, from: firstDateOfMonth)  // địa chỉ tuyệt đối của ngày 1. Cố định: CN=1, T2=2, … T7=7
    return (weekday - calendar.firstWeekday + 7) % 7
  }

  func isToday(_ day: Int) -> Bool {
    // day - 1 vì firstDateOfMonth đã là ngày 1 rồi
    let date = calendar.date(byAdding: .day, value: day - 1, to: firstDateOfMonth)!
    return calendar.isDate(date, inSameDayAs: Date())
  }

  // Chỉ số tháng tuyệt đối: year * 12 + (month - 1).
  // Quy về Int để so sánh/đếm bằng số học, khỏi lôi Date ra so.
  func monthIndex(of date: Date) -> Int {
    let components = calendar.dateComponents([.year, .month], from: date)
    return components.year! * 12 + (components.month! - 1)
  }

  // Cửa sổ 12 tháng tính CẢ tháng hiện tại, nên là -11 chứ không phải -12.
  var allowedMonths: ClosedRange<Int> {
    let currentMonth = monthIndex(of: Date())
    return (currentMonth - 11)...currentMonth
  }

  var canGoBack: Bool { monthIndex(of: anchorDate) > allowedMonths.lowerBound }
  var canGoForward: Bool { monthIndex(of: anchorDate) < allowedMonths.upperBound }

  // Cộng tháng vào firstDateOfMonth chứ KHÔNG vào anchorDate.
  func changeMonth(by value: Int) {
    let target = calendar.date(byAdding: .month, value: value, to: firstDateOfMonth)!
    // Chặn ở đây chứ không chỉ dựa vào .disabled() ngoài UI: swipe hay deep link
    // sau này sẽ gọi thẳng hàm này mà không đi qua Button.
    guard allowedMonths.contains(monthIndex(of: target)) else { return }
    anchorDate = target
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        // .month(.wide) = tên tháng đầy đủ. Tự dịch theo locale:
        // "September 2026" / "tháng 9 năm 2026" / "septiembre de 2026"
        Text(anchorDate.formatted(.dateTime.month(.wide).year()))
          .font(.title2.bold())

        Spacer()

        Button {
          changeMonth(by: -1)
        } label: {
          Image(systemName: "chevron.left")
            .frame(width: 44, height: 44)
        }
        .disabled(!canGoBack)

        Button {
          changeMonth(by: 1)
        } label: {
          Image(systemName: "chevron.right")
            .frame(width: 44, height: 44)
        }
        .disabled(!canGoForward)
      }
      .tint(Color.red)

      HStack(spacing: 0) {
        ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
          Text(symbol)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
      }

      LazyVGrid(columns: columns) {
        ForEach(0..<(leadingBlanks + daysInMonth), id: \.self) { index in
          if index < leadingBlanks {
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
    .padding(24)
    .navigationTitle("Calendar")
    .navigationBarTitleDisplayMode(.inline)
  }
}
