//
//  BirthYearCollectionWheelSheet.swift
//  Draft
//
//  Cùng ca năm sinh như `BirthYearTableWheelSheet`, nhưng dựng bằng
//  `CollectionWheelPicker` (UICollectionView + custom layout).
//
//  Ca không có nhãn đơn vị là chỗ nhìn rõ nhất phần nén khoảng cách: không có
//  chữ `ml`/`cm` ở mép phải kéo mắt đi, chỉ còn cột số và hình dạng bánh xe.
//

import SwiftUI

struct BirthYearCollectionWheelSheet: View {
  @Binding var year: Int
  let rendering: CollectionWheelRendering

  @Environment(\.dismiss) private var dismiss
  @State private var selectedIndex: Int

  static let earliestYear = 1925

  /// Cận trên tính lúc chạy, không viết cứng — xem `BirthYearTableWheelSheet`.
  static var currentYear: Int {
    Calendar.current.component(.year, from: Date())
  }

  static var values: [Int] {
    Array(earliestYear...currentYear)
  }

  init(year: Binding<Int>, rendering: CollectionWheelRendering = .overlaidLists) {
    self.rendering = rendering
    self._year = year
    self._selectedIndex = State(initialValue: Self.nearestIndex(to: year.wrappedValue))
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Chọn năm sinh")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      CollectionWheelPicker(
        values: Self.values.map { String($0) },
        selectedIndex: $selectedIndex,
        rendering: rendering
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
