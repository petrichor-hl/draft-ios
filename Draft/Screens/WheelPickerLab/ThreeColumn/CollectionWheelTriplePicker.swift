//
//  CollectionWheelTriplePicker.swift
//  Draft
//
//  Bản collection của `TableWheelTriplePicker` — ba cột dưới chung một plinth.
//
//  Lý do "ba scroll view chứ không phải một layout ba cột" giống hệt ca hai
//  cột, không chép lại: xem `TableWheelPairPicker`.
//
//  Ca ba cột làm lộ thêm một điều mà hai cột chưa đủ để thấy: cột NGÀY có số
//  hàng THAY ĐỔI (28→31), hai cột kia thì không. Phần nén khoảng cách tính
//  theo khoảng cách tới tâm khung, không theo số hàng, nên cột ngày co dãn dải
//  mà hình dạng bánh xe không đổi — ba cột vẫn cong theo cùng một hình trụ.
//

import SwiftUI

struct CollectionWheelTriplePicker: View {
  var dayValues: [String]
  @Binding var dayIndex: Int

  var monthValues: [String]
  @Binding var monthIndex: Int

  var yearValues: [String]
  @Binding var yearIndex: Int

  var unitLabel: String = ""

  /// Ba bề rộng đặt theo nội dung dài nhất — xem `TableWheelTriplePicker`.
  var dayWidth: CGFloat = 64
  var monthWidth: CGFloat = 140
  var yearWidth: CGFloat = 100

  var metrics: CollectionWheelMetrics = CollectionWheelMetrics(fontSize: 30)

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.centerRowHeight)

      HStack(spacing: 0) {
        CollectionWheelColumn(
          values: dayValues,
          selectedIndex: $dayIndex,
          metrics: metrics
        )
        .frame(width: dayWidth)

        CollectionWheelColumn(
          values: monthValues,
          selectedIndex: $monthIndex,
          metrics: metrics
        )
        .frame(width: monthWidth)

        CollectionWheelColumn(
          values: yearValues,
          selectedIndex: $yearIndex,
          metrics: metrics
        )
        .frame(width: yearWidth)
      }
    }
    .frame(height: metrics.height)
  }
}
