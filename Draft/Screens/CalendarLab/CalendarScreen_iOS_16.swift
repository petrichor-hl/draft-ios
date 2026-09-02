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

  /// Trang đang mở. Khác bản iOS 18: selection của TabView KHÔNG optional,
  /// nó chỉ đổi khi trang đã chốt, không có trạng thái "đang ở giữa hai trang".
  /// Nên ở đây không cần thêm một biến displayedMonth nữa.
  @State private var selectedMonth = MonthCalendar.recentMonths.last!

  /// Chiều cao khung ngoài. Giữ riêng để animate được — xem onChange bên dưới.
  @State private var gridHeight = MonthCalendar.gridHeight(of: MonthCalendar.recentMonths.last!)

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
      // TabView KHÔNG tự co theo nội dung — đây là khác biệt lớn nhất so với
      // ScrollView. Không cho chiều cao thì nó ăn hết chỗ trống.
      // Và giống bản iOS 18: khoá CỐ ĐỊNH 6 hàng, đừng animate frame của chính
      // TabView — nó tự quản lý layout bên trong, đổi bounds từng frame là giật.
      .frame(height: MonthCalendar.maxGridHeight)
      // Khung NGOÀI mới co giãn theo tháng; phần dư của TabView do clipShape cắt.
      .frame(height: gridHeight, alignment: .top)
      .clipShape(.rect)
      // Vuốt tay ghi thẳng vào selection trong transaction của TabView, mà
      // transaction đó tắt animation — nên .animation(_:value:) sẽ không ăn.
      // withAnimation trong onChange mở transaction mới, phủ chung cho cả nút
      // lẫn ngón tay.
      //
      // ĐỪNG sửa warning "onChange(of:perform:) was deprecated in iOS 17".
      // Bản một tham số này là bản DUY NHẤT chạy được trên iOS 16; bản hai tham
      // số (oldValue, newValue) mới là iOS 17+. Warning chỉ hiện vì project build
      // ở 18.6 — typecheck riêng file này với target iOS 16 thì sạch.
      .onChange(of: selectedMonth) { newMonth in
        withAnimation(.snappy) {
          gridHeight = MonthCalendar.gridHeight(of: newMonth)
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
