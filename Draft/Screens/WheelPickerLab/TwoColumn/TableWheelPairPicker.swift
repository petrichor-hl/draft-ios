//
//  TableWheelPairPicker.swift
//  Draft
//
//  Hai cột `TableWheelColumn` dưới chung một plinth.
//
//  Kho này chia thư mục theo SỐ CỘT, không theo ca:
//
//      OneColumn/    máy móc (TableWheelColumn, coordinator, snap, metrics)
//                    + các ca một cột
//      TwoColumn/    cách xếp hai cột  ← file này
//                    + các ca hai cột
//
//  Vì cách XẾP mới là thứ thay đổi theo số cột, còn viên gạch thì không: ca
//  cân nặng cần hai cột và một dấu chấm, ca ngày sinh cần ba cột không dấu
//  ngăn — hai cách xếp khác hẳn nhau, nhưng cùng dùng đúng một
//  `TableWheelColumn` không sửa dòng nào.
//

import SwiftUI

/// Hai cột ĐỘC LẬP dưới CHUNG một plinth — cân nặng `nguyên . lẻ`.
///
/// ## Vì sao là hai scroll view, không phải một layout hai cột
///
/// Với bánh xe, `contentOffset` CHÍNH LÀ state: hàng nào đang chọn = offset
/// đang ở đâu. Mà một `UIScrollView` chỉ có MỘT `contentOffset`. Hai cột cần
/// đứng ở hai chỗ khác nhau và cuộn rời nhau, nên phải là hai scroll view.
///
/// Custom layout đổi được chỗ VẼ của item, nhưng không đẻ thêm được offset thứ
/// hai. Ép một collection view làm hai cột rời thì phải tự gắn pan gesture cho
/// từng vùng, tự giữ offset ảo, rồi tự viết lại giảm tốc + rubber-band + snap
/// theo vận tốc — tức là viết tay lại đúng phần `UIScrollView` đang cho không,
/// mà đó lại là LÝ DO cả kho này chọn table/collection ngay từ đầu.
///
/// ## Cái gì chung, cái gì riêng
///
///     CHUNG    plinth, metrics, dấu ngăn ở giữa
///     RIÊNG    contentOffset, selectedIndex, gesture, momentum, haptic
///
/// Mỗi cột có `UISelectionFeedbackGenerator` riêng, nên cuộn hai cột bằng hai
/// ngón cho hai chuỗi rung độc lập — không phải gộp.
///
/// ## Ràng buộc giữa hai cột KHÔNG nằm ở đây
///
/// View này không biết 200.5 là không hợp lệ. Nó chỉ nhận hai mảng nhãn và hai
/// index. Ai sở hữu ý nghĩa thì người đó lo ràng buộc — xem
/// `WeightTableWheelSheet`.
struct TableWheelPairPicker: View {
  var leadingValues: [String]
  @Binding var leadingIndex: Int
  var trailingValues: [String]
  @Binding var trailingIndex: Int

  /// Chữ đứng yên giữa hai cột — dấu `.` của cân nặng chẳng hạn.
  var separator: String

  var unitLabel: String = ""

  /// Hai bề rộng khác nhau vì hai cột chứa số dài ngắn khác nhau: cột nguyên
  /// phải chứa nổi "200" ở cỡ chữ 40pt, cột lẻ chỉ có một chữ số. Cho bằng nhau
  /// thì cụm số lệch hẳn sang một bên so với dấu chấm.
  var leadingWidth: CGFloat = 100
  var trailingWidth: CGFloat = 60
  var separatorWidth: CGFloat = 24

  var metrics: TableWheelMetrics = .default

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.rowHeight)

      // Cụm hai cột nằm GIỮA khung, còn nhãn đơn vị bám mép phải của plinth —
      // đúng như mockup: `60 . 0` ở giữa, `kg` tách ra bên phải.
      HStack(spacing: 0) {
        TableWheelColumn(
          values: leadingValues,
          selectedIndex: $leadingIndex,
          metrics: metrics
        )
        .frame(width: leadingWidth)

        // Cùng cỡ chữ và cùng độ đậm với hàng ở tâm, để dấu chấm nằm đúng
        // baseline của hai con số hai bên.
        Text(separator)
          .font(.system(size: metrics.fontSize, weight: .bold))
          .frame(width: separatorWidth)

        TableWheelColumn(
          values: trailingValues,
          selectedIndex: $trailingIndex,
          metrics: metrics
        )
        .frame(width: trailingWidth)
      }
    }
    .frame(height: metrics.height)
  }
}
