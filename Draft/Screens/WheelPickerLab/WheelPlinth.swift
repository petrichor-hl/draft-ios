//
//  WheelPlinth.swift
//  Draft
//
//  Cái nền bo góc nằm sau hàng ĐANG CHỌN, kèm nhãn đơn vị ở mép phải.
//
//  Tách ra khỏi hai file picker vì ca hai cột làm lộ một điều: plinth chưa bao
//  giờ thuộc về cột nào. Ở bản một cột thì không thấy — plinth rộng bằng đúng
//  cột nên tưởng là của cột. Ở bản hai cột, MỘT plinth trải qua cột nguyên, dấu
//  chấm, cột lẻ và cả chữ `kg`. Nó là nền của HÀNG, ở cấp cha.
//
//  Đây cũng là ranh giới mà `Picker(.wheel)` hệ thống không vượt được: mỗi
//  picker tự vẽ plinth ôm đúng bề rộng của nó, đặt hai cái cạnh nhau là ra hai
//  plinth rời. Xem `WaterGoalSystemPickerSheet`, dòng ✗ "Plinth: bề rộng, màu,
//  bo góc".
//

import SwiftUI

struct WheelPlinth: View {
  var unitLabel: String

  /// Truyền vào chứ không tự tính, vì hai cách dựng đo khác nhau:
  /// bản table lấy `rowHeight` (hàng nào cũng cao bằng nhau), bản collection
  /// lấy `centerRowHeight` (hàng ở tâm cao hơn hàng ngoài rìa).
  var height: CGFloat

  var body: some View {
    Text(unitLabel)
      .font(.system(size: 20, weight: .semibold))
      .padding(.trailing, 16)
      .frame(maxWidth: .infinity, alignment: .trailing)
      .frame(height: height)
      .background(
        Color(uiColor: .secondarySystemBackground),
        in: .rect(cornerRadius: 16)
      )
  }
}
