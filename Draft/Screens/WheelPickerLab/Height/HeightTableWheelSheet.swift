//
//  HeightTableWheelSheet.swift
//  Draft
//
//  Chiều cao — một cột, bước 1cm, dựng bằng `TableWheelPicker` (UITableView).
//
//  Khác ca nước uống ở đúng hai điểm, cả hai đều là DỮ LIỆU chứ không phải
//  cách dựng:
//
//    • bước 1 thay vì 250 → 101 hàng thay vì 17. Đây là ca để xem việc tái
//      dùng cell có thật sự cần không: cuộn một mạch từ 120 lên 220 mà không
//      giật thì `UITableView` đang làm đúng việc của nó.
//    • giá trị mặc định nằm sẵn trên lưới nên `nearestIndex` luôn khớp — khác
//      2600ml ở ca nước uống vốn rơi giữa hai hàng.
//
//  Đặt cạnh `HeightCollectionWheelSheet` để so bằng ngón tay.
//

import SwiftUI

struct HeightTableWheelSheet: View {
  @Binding var valueCm: Int

  @Environment(\.dismiss) private var dismiss
  @State private var selectedIndex: Int

  static let range = 120...220
  static let values: [Int] = Array(range)

  /// Khởi tạo trong `init` chứ không phải `onAppear` — lý do đầy đủ ở
  /// `WaterGoalTableWheelSheet`.
  init(valueCm: Binding<Int>) {
    self._valueCm = valueCm
    self._selectedIndex = State(initialValue: Self.nearestIndex(to: valueCm.wrappedValue))
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Điều chỉnh chiều cao")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      TableWheelPicker(
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
