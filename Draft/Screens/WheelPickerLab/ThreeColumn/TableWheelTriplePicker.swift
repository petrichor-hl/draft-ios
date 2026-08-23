//
//  TableWheelTriplePicker.swift
//  Draft
//
//  Ba cột `TableWheelColumn` dưới chung một plinth — ngày / tháng / năm.
//
//  Vẫn đúng viên gạch của ca một cột, không sửa một dòng. So với
//  `TableWheelPairPicker` thì khác hai chỗ, cả hai đều thuộc về CÁCH XẾP:
//
//    • không có dấu ngăn. Ca cân nặng cần dấu `.` vì hai cột ghép lại thành
//      MỘT con số; ở đây ba cột là ba đại lượng riêng, đặt cạnh nhau là đủ.
//    • bề rộng ba cột lệch nhau nhiều hơn: "tháng 12" dài gấp đôi "2026" và
//      gấp bốn "11". Chia đều thì cụm chữ lệch hẳn khỏi tâm plinth.
//
//  Ràng buộc giữa các cột KHÔNG nằm ở đây. View này không biết tháng 2 có bao
//  nhiêu ngày — xem `EventDateTableWheelSheet` và `DateWheelData`.
//

import SwiftUI

struct TableWheelTriplePicker: View {
  var dayValues: [String]
  @Binding var dayIndex: Int

  var monthValues: [String]
  @Binding var monthIndex: Int

  var yearValues: [String]
  @Binding var yearIndex: Int

  var unitLabel: String = ""

  /// Ba bề rộng đặt theo nội dung dài nhất của từng cột, ở cỡ chữ `metrics.fontSize`:
  /// "31" · "tháng 12" · "2031".
  var dayWidth: CGFloat = 64
  var monthWidth: CGFloat = 140
  var yearWidth: CGFloat = 100

  /// Cỡ chữ nhỏ hơn mặc định (40) vì ba cột phải nằm vừa một hàng. Ca một cột
  /// và hai cột không gặp chuyện này nên vẫn để 40.
  var metrics: TableWheelMetrics = TableWheelMetrics(fontSize: 30)

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.rowHeight)

      HStack(spacing: 0) {
        TableWheelColumn(
          values: dayValues,
          selectedIndex: $dayIndex,
          metrics: metrics
        )
        .frame(width: dayWidth)

        TableWheelColumn(
          values: monthValues,
          selectedIndex: $monthIndex,
          metrics: metrics
        )
        .frame(width: monthWidth)

        TableWheelColumn(
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
