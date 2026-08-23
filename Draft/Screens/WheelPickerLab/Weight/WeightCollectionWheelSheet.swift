//
//  WeightCollectionWheelSheet.swift
//  Draft
//
//  Cùng ca cân nặng như `WeightTableWheelSheet`, nhưng dựng bằng
//  `CollectionWheelPairPicker` (UICollectionView + custom layout).
//
//  Ba khối lý thuyết — canonical là Int phần mười kg, ràng buộc chạm trần 200,
//  và chỗ cú kẹp rơi vào khoảng lặng của `updateUIView` — nằm đủ ở file table,
//  không chép lại. Ở đây chỉ ghi cái RIÊNG của bản này.
//
//  ## Cái riêng: nén khoảng cách chạy độc lập cho từng cột
//
//  Hai cột không biết gì về nhau, mỗi cột tự tính lượng nén theo khoảng cách
//  tới tâm KHUNG CỦA NÓ. Nhưng vì hai khung cao bằng nhau và cùng metrics, tâm
//  của chúng nằm trên một đường ngang — nên hai cột cong theo cùng một hình
//  trụ mà không cần đồng bộ gì cả.
//
//  Đây là chỗ đáng đặt cạnh bản table nhất trong cả kho: cùng một dữ liệu,
//  cùng một plinth, cùng một dấu chấm, khác đúng chuyện hàng ngoài rìa có xích
//  vào tâm hay không. Mở lần lượt hai sheet rồi vuốt để quyết xem cái cong đó
//  có đáng công không.
//
//  ## Một chi tiết dễ tưởng là bug
//
//  Cột lẻ chỉ có 10 hàng. Cuộn tới hai đầu thì phần nén làm hàng cuối trông
//  "hụt" hơn cột nguyên đang ở giữa dải — không phải lỗi, chỉ là hai cột đang ở
//  hai chỗ khác nhau trên cùng một hình trụ.
//

import SwiftUI

struct WeightCollectionWheelSheet: View {
  /// Cân nặng tính bằng PHẦN MƯỜI kg — 600 là 60.0kg.
  @Binding var tenths: Int

  @Environment(\.dismiss) private var dismiss
  @State private var integerIndex: Int
  @State private var decimalIndex: Int

  static let integerRange = 30...200
  static let integerValues: [Int] = Array(integerRange)
  static let decimalValues: [Int] = Array(0...9)

  static var minTenths: Int { integerRange.lowerBound * 10 }
  static var maxTenths: Int { integerRange.upperBound * 10 }

  init(tenths: Binding<Int>) {
    self._tenths = tenths
    let clamped = min(max(tenths.wrappedValue, Self.minTenths), Self.maxTenths)
    self._integerIndex = State(initialValue: clamped / 10 - Self.integerRange.lowerBound)
    self._decimalIndex = State(initialValue: clamped % 10)
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Cân nặng hiện tại")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      CollectionWheelPairPicker(
        leadingValues: Self.integerValues.map { String($0) },
        leadingIndex: $integerIndex,
        trailingValues: Self.decimalValues.map { String($0) },
        trailingIndex: $decimalIndex,
        separator: ".",
        unitLabel: "kg"
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)
      .onChange(of: integerIndex) { _, _ in enforceCeiling() }
      .onChange(of: decimalIndex) { _, _ in enforceCeiling() }

      Button {
        tenths = Self.integerValues[integerIndex] * 10 + Self.decimalValues[decimalIndex]
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

  /// Xem `WeightTableWheelSheet` để biết vì sao cần cả hai chiều và vì sao
  /// điều kiện `decimalIndex != 0` là bắt buộc chứ không phải tối ưu.
  private var isAtCeiling: Bool {
    Self.integerValues[integerIndex] == Self.integerRange.upperBound
  }

  private func enforceCeiling() {
    guard isAtCeiling, decimalIndex != 0 else { return }
    decimalIndex = 0
  }
}
