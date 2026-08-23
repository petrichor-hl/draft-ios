//
//  AgeRangeCollectionWheelScreen.swift
//  Draft
//
//  Cùng ca khoảng tuổi như `AgeRangeTableWheelScreen`, nhưng dựng bằng
//  `CollectionWheelPairPicker`.
//
//  Năm khối lý thuyết — ràng buộc theo giá trị cột kia, đùn thay vì kẹp,
//  canonical `ClosedRange` tự gánh ràng buộc, vì sao `onChange` đủ ở đây, và
//  những gì đổi khi chuyển từ sheet sang màn đẩy — có đủ ở file table, không
//  chép lại. Ở đây chỉ ghi cái RIÊNG của bản này.
//
//  ## Cái riêng 1: hai bánh xe giống hệt nhau
//
//  Đây là ca duy nhất trong kho mà hai cột đọc CÙNG một mảng nhãn. Ở bản table
//  điều đó chỉ là một sự trùng lặp không ai để ý; ở bản collection thì phần nén
//  làm nó hiện ra — hai cột cong y hệt, cùng một dải số, khác đúng chỗ chúng
//  đang đứng. Nhìn như một tờ giấy bị cắt đôi rồi trượt lệch.
//
//  ## Cái riêng 2: cú đùn đọc khác hẳn hai bản
//
//  Cùng một dòng code (`updateUIView`, `animated: false`) nhưng cảm giác khác:
//
//    bản table       hàng nào cũng cao 60, cột bị đùn trượt phẳng lên một hàng.
//    bản collection  hàng vừa dời chỗ vừa ĐỔI CHIỀU CAO theo khoảng cách tới
//                    tâm, nên cùng cú nhảy ấy kèm một nhịp phình–xẹp.
//
//  Chỗ đáng nhìn nhất khi so hai bản: đặt hai cận sát nhau (30 và 31), rồi kéo
//  cận dưới lên một mạch. Cột trên bị đùn suốt quãng đó, và ở bản collection
//  nó "thở" theo từng hàng.
//

import SwiftUI

struct AgeRangeCollectionWheelScreen: View {
  @Binding var range: ClosedRange<Int>

  @Environment(\.dismiss) private var dismiss
  @State private var lowerIndex: Int
  @State private var upperIndex: Int

  static let bounds = 18...80
  static let values: [Int] = Array(bounds)

  init(range: Binding<ClosedRange<Int>>) {
    self._range = range
    self._lowerIndex = State(initialValue: Self.index(of: range.wrappedValue.lowerBound))
    self._upperIndex = State(initialValue: Self.index(of: range.wrappedValue.upperBound))
  }

  var body: some View {
    VStack(spacing: 0) {
      CollectionWheelPairPicker(
        leadingValues: Self.labels,
        leadingIndex: $lowerIndex,
        trailingValues: Self.labels,
        trailingIndex: $upperIndex,
        separator: "–",
        unitLabel: "tuổi",
        trailingWidth: 100,
        separatorWidth: 40
      )
      .padding(.horizontal, 24)
      .padding(.top, 24)
      .onChange(of: lowerIndex) { _, _ in pushUpper() }
      .onChange(of: upperIndex) { _, _ in pushLower() }

      Spacer()

      Button {
        range = Self.values[lowerIndex]...Self.values[upperIndex]
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
    .navigationTitle("Khoảng tuổi")
    .navigationBarTitleDisplayMode(.inline)
  }

  private static let labels: [String] = values.map { String($0) }

  private static func index(of age: Int) -> Int {
    min(max(age, bounds.lowerBound), bounds.upperBound) - bounds.lowerBound
  }

  /// Xem `AgeRangeTableWheelScreen` để biết vì sao là đùn chứ không phải kẹp, và
  /// vì sao dấu so sánh NGẶT là thứ chặn vòng lặp.
  private func pushUpper() {
    guard lowerIndex > upperIndex else { return }
    upperIndex = lowerIndex
  }

  private func pushLower() {
    guard upperIndex < lowerIndex else { return }
    lowerIndex = upperIndex
  }
}
