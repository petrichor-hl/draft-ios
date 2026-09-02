//
//  CalendarScreen_iOS_18.swift
//  Draft
//

import SwiftUI

/// Lịch tháng, phân trang bằng ScrollView + .scrollTargetBehavior(.paging).
/// Cách này cần iOS 17+. Bản cho iOS 16 nằm ở CalendarScreen_iOS_16.swift.
///
/// Phần khung (tiêu đề, nút ‹ ›, hàng weekday, thẻ trắng) cố tình lặp lại ở cả
/// hai file thay vì tách ra dùng chung: hai bản sẽ còn khác nhau thêm nữa khi
/// phân trang thật (TabView bắt buộc có chiều cao cố định, ScrollView thì không),
/// và mỗi file đọc một mình vẫn hiểu được là điểm chính của lab.
struct CalendarScreen_iOS_18: View {
  private let months = MonthCalendar.recentMonths

  @State private var selectedMonth = MonthCalendar.recentMonths.last!

  // Không cần tính biên: months CHÍNH LÀ giới hạn, chỉ cần xem đang ở đâu trong mảng.
  private var canGoBack: Bool { selectedMonth > months.first! }
  private var canGoForward: Bool { selectedMonth < months.last! }

  /// Chặn ở đây chứ không chỉ dựa vào .disabled() ngoài UI:
  /// vuốt tay và deep link sau này gọi thẳng hàm này, không đi qua Button.
  private func changeMonth(by value: Int) {
    guard let current = months.firstIndex(of: selectedMonth) else { return }
    let target = current + value
    guard months.indices.contains(target) else { return }

    withAnimation(.snappy) {
      selectedMonth = months[target]
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        // .month(.wide) = tên tháng đầy đủ. Tự dịch theo locale:
        // "September 2026" / "tháng 9 năm 2026" / "septiembre de 2026"
        Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
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

      // Hàng weekday nằm NGOÀI phần phân trang nên nó đứng yên khi lật tháng.
      // (App tham chiếu cho hàng này trượt cùng lưới, nhìn frame giữa chừng thấy
      //  "S S | M T W T F" — chữ cái xáo trộn. Ở đây cố tình làm khác.)
      HStack(spacing: 0) {
        ForEach(Array(MonthCalendar.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
          Text(symbol)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
      }

      // TODO: thay bằng ScrollView paging
      MonthGrid(month: selectedMonth)
    }
    .padding(24)
    .background(Color(.white), in: .rect(cornerRadius: 30))
    .padding(16)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color(red: 0.99, green: 0.95, blue: 0.86))
    .navigationTitle("Calendar (iOS 18)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CalendarScreen_iOS_18()
  }
}
