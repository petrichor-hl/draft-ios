//
//  CalendarScreen_iOS_16.swift
//  Draft
//

import SwiftUI

/// Lịch tháng, phân trang bằng TabView + .tabViewStyle(.page).
/// Cách này chạy từ iOS 14, dùng được khi phải support iOS 16.
/// Bản dùng ScrollView paging (iOS 17+) nằm ở CalendarScreen_iOS_18.swift.
///
/// Khác biệt lớn nhất sẽ lộ ra khi phân trang thật: TabView KHÔNG tự co theo
/// nội dung, bắt buộc phải cho nó .frame(height:) — nên bản này sẽ phải tự
/// tính chiều cao, còn bản iOS 18 thì không.
struct CalendarScreen_iOS_16: View {
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
      HStack(spacing: 0) {
        ForEach(Array(MonthCalendar.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
          Text(symbol)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
      }

      // TODO: thay bằng TabView .page
      MonthGrid(month: selectedMonth)
    }
    .padding(24)
    .background(Color(.white), in: .rect(cornerRadius: 30))
    .padding(16)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color(red: 0.99, green: 0.95, blue: 0.86))
    .navigationTitle("Calendar (iOS 16)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CalendarScreen_iOS_16()
  }
}
