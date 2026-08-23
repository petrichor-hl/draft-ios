//
//  HeightCollectionWheelSheet.swift
//  Draft
//
//  Cùng ca chiều cao như `HeightTableWheelSheet`, nhưng dựng bằng
//  `CollectionWheelPicker` (UICollectionView + custom layout).
//
//  Với 101 hàng thì khác biệt giữa hai bản rõ hơn hẳn ca nước uống 17 hàng:
//  cuộn nhanh qua cả dải, bản collection phải tính lại layout attributes cho
//  từng hàng theo khoảng cách tới tâm, còn bản table chỉ đổi `transform`.
//  Nếu có bản nào rớt khung hình thì đây là ca lộ ra.
//

import SwiftUI

struct HeightCollectionWheelSheet: View {
  @Binding var valueCm: Int

  @Environment(\.dismiss) private var dismiss
  @State private var selectedIndex: Int

  static let range = 120...220
  static let values: [Int] = Array(range)

  init(valueCm: Binding<Int>) {
    self._valueCm = valueCm
    self._selectedIndex = State(initialValue: Self.nearestIndex(to: valueCm.wrappedValue))
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Điều chỉnh chiều cao")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      CollectionWheelPicker(
        values: Self.values.map { String($0) },
        selectedIndex: $selectedIndex,
        unitLabel: "cm"
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)

      Button {
        valueCm = Self.values[selectedIndex]
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
