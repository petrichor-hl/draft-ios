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

  /// Trang đang mở — chỉ dùng để nối với selection của TabView.
  /// Khác bản iOS 18: không optional, TabView chỉ đổi selection khi trang đã chốt
  /// chứ không có trạng thái "đang ở giữa hai trang".
  @State private var selectedMonth = MonthCalendar.recentMonths.last!

  /// Tháng đang HIỂN THỊ — tiêu đề, nút và chiều cao thẻ đều đọc biến này.
  /// Tách khỏi selectedMonth để phần hiển thị đổi có animation, còn phần phân
  /// trang thì không dính animation của mình. Cùng mô hình với bản iOS 18.
  @State private var displayedMonth = MonthCalendar.recentMonths.last!

  // Không cần tính biên: months CHÍNH LÀ giới hạn, chỉ cần xem đang ở đâu trong mảng.
  private var canGoBack: Bool { displayedMonth > months.first! }
  private var canGoForward: Bool { displayedMonth < months.last! }

  /// Chặn ở đây chứ không chỉ dựa vào .disabled() ngoài UI:
  /// vuốt tay và deep link sau này gọi thẳng hàm này, không đi qua Button.
  private func changeMonth(by value: Int) {
    guard let current = months.firstIndex(of: displayedMonth) else { return }
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
        Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
          .font(.title2.bold())
          .animation(.none)

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

      TabView(selection: $selectedMonth) {
        ForEach(months, id: \.self) { month in
          MonthGrid(month: month)
            // Mọi trang cao BẰNG NHAU (6 hàng), neo lên đỉnh. Không ép thì TabView
            // đưa cả khung cho trang và lưới bị căn giữa; hai tháng khác số hàng
            // sẽ không thẳng hàng nhau lúc lật.
            .frame(height: MonthCalendar.maxGridHeight, alignment: .top)
            // .tag phải CÙNG KIỂU với selection (Date), nếu không TabView im lặng
            // không nhận ra trang nào đang mở — không lỗi biên dịch, chỉ là không chạy.
            .tag(month)
        }
      }
      // .never = ẩn hàng chấm trắng mặc định của page style
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(height: MonthCalendar.maxGridHeight)
      .frame(height: MonthCalendar.gridHeight(of: displayedMonth), alignment: .top)
      .clipShape(.rect)
      // ĐỪNG sửa warning "onChange(of:perform:) was deprecated in iOS 17".
      // Bản một tham số này là bản DUY NHẤT chạy được trên iOS 16; bản hai tham
      // số (oldValue, newValue) mới là iOS 17+. Warning chỉ hiện vì project build
      // ở 18.6 — typecheck riêng file này với target iOS 16 thì sạch.
      .onChange(of: selectedMonth) { newMonth in
        withAnimation(.linear(duration: 0.2)) {
          displayedMonth = newMonth
        }
      }
    }
    .padding(20)
    .background(Color(.white), in: .rect(cornerRadius: 30))
    .padding(16)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color(.secondarySystemBackground))
    .navigationTitle("Calendar (iOS 16)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CalendarScreen_iOS_16()
  }
}
