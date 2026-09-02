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
  // Tháng đang hiển thị. Bước 4 sẽ đổi thành @State để bấm ‹ › được.
  let anchorDate = Date()

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

  var body: some View {
    let _ = print("daysInMonth = \(daysInMonth)")
    let _ = print("leadingBlanks = \(leadingBlanks)")
    
    VStack(spacing: 0) {
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
    .navigationTitle("Calendar")
    .navigationBarTitleDisplayMode(.inline)
  }
}
