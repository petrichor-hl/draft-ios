//
//  EventDateCollectionWheelSheet.swift
//  Draft
//
//  Cùng ca ngày sự kiện như `EventDateTableWheelSheet`, nhưng dựng bằng
//  `CollectionWheelTriplePicker`.
//
//  Ba khối lý thuyết — cột ngày co dãn số hàng, kẹp trong setter thay vì
//  `onChange`, và vì sao luật lịch nằm ở file riêng — có đủ ở file table,
//  không chép lại. Ở đây chỉ ghi cái RIÊNG của bản này.
//
//  ## Cái riêng: dải co dãn không làm đổi hình bánh xe
//
//  Phần nén khoảng cách tính theo khoảng cách tới TÂM KHUNG, không theo số
//  hàng của cột. Nên cột ngày tụt từ 31 xuống 28 hàng thì chỉ dải cuộn ngắn
//  lại, còn độ cong giữ nguyên — ba cột vẫn nằm trên cùng một hình trụ.
//
//  Chỗ đáng nhìn nhất khi so hai bản: kéo tháng qua lại giữa 01 và 02 trong
//  lúc đang chọn ngày 31. Bản table kéo hàng về bằng `settle`; bản collection
//  làm y hệt, nhưng vì hàng rìa còn bị nén nên cú trườn đó đọc khác đi.
//

import SwiftUI

struct EventDateCollectionWheelSheet: View {
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

      CollectionWheelTriplePicker(
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

  private var dayValues: [String] {
    let count = DateWheelData.dayCount(
      month: monthIndex + 1,
      year: DateWheelData.years[yearIndex]
    )
    return (1...count).map { String($0) }
  }

  /// Xem `EventDateTableWheelSheet` để biết vì sao là binding gói lại chứ
  /// không phải `.onChange`.
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
