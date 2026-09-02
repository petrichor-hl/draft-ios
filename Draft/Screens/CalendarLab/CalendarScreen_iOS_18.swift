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

  /// Trang đang mở. Optional vì .scrollPosition(id:) yêu cầu vậy — trong lúc
  /// cuộn giữa hai trang nó tạm thành nil, chưa trang nào "đang được chọn".
  ///
  /// Đây là NGUỒN DUY NHẤT: ngón tay cuộn thì ScrollView ghi vào đây,
  /// bấm nút thì mình ghi vào đây rồi ScrollView tự cuộn theo. Một biến, hai chiều.
  @State private var scrolledMonth: Date? = MonthCalendar.recentMonths.last

  /// Tháng đang HIỂN THỊ — tiêu đề, nút và chiều cao thẻ đều đọc biến này.
  ///
  /// Phải là @State riêng chứ không phải `scrolledMonth ?? months.last!`:
  /// giữa hai trang scrolledMonth là nil, mà fallback về months.last thì đang
  /// xem July sẽ nhảy về September một nhịp. Giữ state riêng thì lúc nil nó
  /// đơn giản là không đổi.
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

    // Chỉ cần gán — .scrollPosition(id:) thấy giá trị đổi là tự cuộn tới trang đó.
    // Không phải gọi ScrollViewReader hay proxy.scrollTo gì cả.
    withAnimation(.snappy) {
      scrolledMonth = months[target]
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        // .month(.wide) = tên tháng đầy đủ. Tự dịch theo locale:
        // "September 2026" / "tháng 9 năm 2026" / "septiembre de 2026"
        Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
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

      ScrollView(.horizontal) {
        LazyHStack(alignment: .top, spacing: 0) {
          ForEach(months, id: \.self) { month in
            MonthGrid(month: month)
              // Mỗi trang rộng đúng bằng container. Thiếu dòng này thì trang chỉ
              // rộng bằng nội dung và paging không có mốc để snap.
              .containerRelativeFrame(.horizontal)
              // Mọi trang cao BẰNG NHAU (6 hàng) để hàng của hai tháng thẳng nhau
              // lúc lật. Khung ngoài mới là thứ co giãn theo tháng.
              .frame(height: MonthCalendar.maxGridHeight, alignment: .top)
          }
        }
        // Đánh dấu: các con của stack này LÀ các mốc snap.
        // Đặt trên stack chứ không phải trên ScrollView.
        .scrollTargetLayout()
      }
      // Cuộn xong thì dừng đúng một trang, không trôi tự do.
      .scrollTargetBehavior(.paging)
      // Nối hai chiều với scrolledMonth: đọc để cuộn, ghi khi người dùng vuốt.
      .scrollPosition(id: $scrolledMonth)
      .scrollIndicators(.hidden)
      // BẮT BUỘC: ScrollView tham lam chiều dọc — không chặn thì nó ăn hết chỗ
      // trống rồi căn giữa lưới, và .frame của MonthGrid không cản được.
      //
      // Chiều cao theo ĐÚNG tháng đang mở, nên thẻ co giãn 4-6 hàng.
      // Trang cao hơn khung sẽ bị cắt trong lúc trượt rồi khung đuổi theo sau —
      // app tham chiếu cũng vậy: giữa chừng lật sang August mới thấy 5 hàng.
      .frame(height: MonthCalendar.gridHeight(of: displayedMonth))
      // Trang luôn cao 6 hàng còn khung chỉ 4-6 hàng, nên phần dư phải cắt.
      // Cùng bài học với SingleAccordionScreen: khung co ngay, nội dung theo sau,
      // không cắt thì nó tràn ra ngoài viền thẻ.
      .clipShape(.rect)
      // Vì sao không dùng .animation(.snappy, value:) ở đây: mọi cập nhật do
      // CUỘN sinh ra đều mang transaction có cờ "tắt animation", và cờ đó thắng
      // — bấm nút thì mượt, vuốt tay thì chiều cao nhảy phựt.
      // withAnimation trong onChange mở một transaction MỚI nên thoát được cờ đó,
      // và phủ chung cho cả hai đường vào (nút lẫn ngón tay).
      .onChange(of: scrolledMonth) { _, newMonth in
        // nil = đang ở giữa hai trang, chưa chốt tháng nào -> giữ nguyên
        guard let newMonth else { return }

        withAnimation(.snappy) {
          displayedMonth = newMonth
        }
      }
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
