//
//  EventDateTableWheelSheet.swift
//  Draft
//
//  Ngày sự kiện — BA cột (ngày / tháng / năm), dựng bằng `TableWheelTriplePicker`.
//
//  Phần cuộn vẫn là `TableWheelColumn` của ca một cột, không sửa dòng nào. Cái
//  mới nằm ở chỗ ràng buộc giữa các cột đã đổi CHẤT so với ca cân nặng.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  1. SỐ HÀNG CỦA MỘT CỘT THAY ĐỔI THEO CỘT KHÁC
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Ca cân nặng: hai cột luôn có 171 và 10 hàng, chỉ GIÁ TRỊ bị kẹp (lẻ về 0).
//  Ca này: cột ngày có 28, 29, 30 hay 31 hàng tuỳ tháng và năm. Mảng nguồn co
//  dãn ngay dưới chân bánh xe.
//
//  Nguy hiểm nằm ở khoảng giữa: đang chọn 31/01, người dùng kéo tháng sang 02.
//  Nếu `dayIndex` (30) còn nguyên trong lúc `dayValues` đã tụt xuống 28 phần
//  tử thì `dayValues[30]` là crash — đúng cảnh đã ghi trước trong
//  `TableWheelPairPicker`.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  2. KẸP TRONG SETTER, KHÔNG PHẢI TRONG `onChange`
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Ca cân nặng kẹp bằng `.onChange`. Ở đây không đủ, vì `onChange` chạy SAU
//  khi SwiftUI đã dựng lại `body`:
//
//      bánh xe ghi monthIndex = 1
//      → body chạy với tháng 2 (28 hàng) NHƯNG dayIndex vẫn 30   ← khoảng chết
//      → onChange mới kẹp dayIndex về 27
//      → body chạy lại
//
//  Ở khoảng chết đó `updateUIView` đã kịp tính offset cho hàng 30 trên một cột
//  chỉ còn 28 hàng, và `values[30]` đã kịp bị đọc.
//
//  Bọc binding lại thì hai lần gán nằm trong CÙNG một lượt cập nhật, nên trạng
//  thái lệch kia không bao giờ tồn tại. `onChange` là phản ứng SAU sự thật;
//  binding gói lại là chặn TRƯỚC khi sự thật kịp sai.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  3. VÌ SAO LUẬT LỊCH NẰM Ở FILE RIÊNG
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Ca cân nặng chép luật vào cả hai sheet, chấp nhận được vì nó là một dòng
//  `if`. Luật ở đây là năm nhuận, và nó có ngoại lệ thật (1900 không nhuận,
//  2000 có) — thứ không nên viết hai lần. Xem `DateWheelData`.
//

import SwiftUI

struct EventDateTableWheelSheet: View {
  @Binding var date: WheelDate

  @Environment(\.dismiss) private var dismiss

  @State private var dayIndex: Int
  @State private var monthIndex: Int
  @State private var yearIndex: Int

  init(date: Binding<WheelDate>) {
    self._date = date
    let value = date.wrappedValue
    let years = DateWheelData.years
    let yearIndex = years.firstIndex(of: value.year) ?? 0
    let monthIndex = min(max(value.month - 1, 0), DateWheelData.months.count - 1)

    self._yearIndex = State(initialValue: yearIndex)
    self._monthIndex = State(initialValue: monthIndex)
    // Kẹp ngay từ đầu: giá trị lưu có thể là 31/01, mà người dùng vừa đổi máy
    // sang một tháng ngắn hơn thì sao cũng phải về hàng cuối.
    self._dayIndex = State(
      initialValue: DateWheelData.clampedDayIndex(
        value.day - 1,
        month: monthIndex + 1,
        year: years[yearIndex]
      )
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Sự kiện diễn ra khi nào?")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      TableWheelTriplePicker(
        dayValues: dayValues,
        dayIndex: $dayIndex,
        monthValues: DateWheelData.months.map(DateWheelData.monthLabel),
        monthIndex: clampingBinding(for: $monthIndex),
        yearValues: DateWheelData.years.map { String($0) },
        yearIndex: clampingBinding(for: $yearIndex)
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)

      Button {
        date = WheelDate(
          day: dayIndex + 1,
          month: monthIndex + 1,
          year: DateWheelData.years[yearIndex]
        )
        dismiss()
      } label: {
        Text("Cập nhật")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 18)
          .background(Color.black, in: .capsule)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
  }

  /// Số hàng của cột ngày, tính lại mỗi lần tháng hoặc năm đổi.
  private var dayValues: [String] {
    let count = DateWheelData.dayCount(
      month: monthIndex + 1,
      year: DateWheelData.years[yearIndex]
    )
    return (1...count).map { String($0) }
  }

  /// Binding gói lại: gán giá trị mới RỒI kẹp ngày, trong cùng một lượt.
  /// Lý do không dùng `.onChange` nằm ở khối 2 đầu file.
  private func clampingBinding(for source: Binding<Int>) -> Binding<Int> {
    Binding {
      source.wrappedValue
    } set: { newValue in
      source.wrappedValue = newValue
      dayIndex = DateWheelData.clampedDayIndex(
        dayIndex,
        month: monthIndex + 1,
        year: DateWheelData.years[yearIndex]
      )
    }
  }
}
