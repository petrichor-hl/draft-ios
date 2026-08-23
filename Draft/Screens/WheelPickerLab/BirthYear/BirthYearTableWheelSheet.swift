//
//  BirthYearTableWheelSheet.swift
//  Draft
//
//  Năm sinh — một cột TRẦN, dựng bằng `TableWheelPicker` (UITableView).
//
//  "Trần" = không có nhãn đơn vị. Plinth vẫn còn, vì nó là vạch chỉ chỗ đang
//  chọn chứ không phải cái nền cho chữ `ml` hay `cm`.
//
//  Hai điều riêng của ca này:
//
//    • Cận trên là NĂM HIỆN TẠI, tính lúc chạy. Viết cứng 2026 thì sang năm
//      sau lab sai mà không ai biết.
//    • Số năm KHÔNG được format theo locale: `Text("\(1990)")` cho ra "1.990".
//      Ở đây an toàn vì component nhận `[String]` và ta tự `String(năm)`,
//      nhưng chỗ nào hiển thị năm ngoài bánh xe thì phải nhớ `verbatim`.
//

import SwiftUI

struct BirthYearTableWheelSheet: View {
  @Binding var year: Int

  @Environment(\.dismiss) private var dismiss
  @State private var selectedIndex: Int

  static let earliestYear = 1925

  /// Cận trên tính lúc chạy, không viết cứng.
  static var currentYear: Int {
    Calendar.current.component(.year, from: Date())
  }

  static var values: [Int] {
    Array(earliestYear...currentYear)
  }

  init(year: Binding<Int>) {
    self._year = year
    self._selectedIndex = State(initialValue: Self.nearestIndex(to: year.wrappedValue))
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Chọn năm sinh")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      TableWheelPicker(
        values: Self.values.map { String($0) },
        selectedIndex: $selectedIndex
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)

      Button {
        year = Self.values[selectedIndex]
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

  private static func nearestIndex(to value: Int) -> Int {
    values.enumerated()
      .min { abs($0.element - value) < abs($1.element - value) }?
      .offset ?? 0
  }
}
