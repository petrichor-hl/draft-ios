//
//  WeightTableWheelSheet.swift
//  Draft
//
//  Cân nặng — HAI cột (nguyên . lẻ), dựng bằng `TableWheelPairPicker`.
//
//  Phần cuộn không có gì mới: mỗi cột vẫn là đúng cái `TableWheelColumn` của ca
//  một cột, không sửa một dòng. Cái mới nằm ở ba chỗ khác.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  1. GIÁ TRỊ LƯU ≠ GIÁ TRỊ HIỂN THỊ → phải có một CANONICAL
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Bánh xe cho ra hai số nguyên rời (60 và 0), phải ghép lại thành một giá trị.
//  Ghép thành `Double` 60.1 là sai ngay từ đầu:
//
//      0.1 không biểu diễn được chính xác trong nhị phân. `60.1` thật ra là
//      60.099999999999994316..., nên `weight == 60.1` là xổ số, và cộng dồn
//      thì sai số lớn dần.
//
//  Canonical ở đây là `Int` PHẦN MƯỜI kg: 600 nghĩa là 60.0kg. Tách và ghép
//  đều là số học nguyên, không có sai số nào:
//
//      tách   kg = tenths / 10        lẻ = tenths % 10
//      ghép   tenths = kg * 10 + lẻ
//
//  Chỉ đổi sang chuỗi "60.0" ở lúc HIỂN THỊ, và bằng nội suy chuỗi thủ công
//  chứ không qua formatter số — xem cảnh báo locale ở `TableWheelLabScreen`.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  2. RÀNG BUỘC GIỮA HAI CỘT — và vì sao nó tốn hơn vẻ ngoài
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Hai cột cuộn rời nhau, nhưng KHÔNG hoàn toàn độc lập: chạm trần 200 thì
//  phần lẻ buộc về 0, vì 200.5 nằm ngoài dải. Đây là bản thu nhỏ của ca ngày
//  sinh (31/01 → tháng 02 phải kẹp ngày lại).
//
//  Viết `decimalIndex = 0` là xong phần STATE. Phần khó là bánh xe có đi theo
//  hay không, và nó hỏng ở hai chỗ khác nhau:
//
//    • Kẹp lúc cột KIA đang cuộn.  Người dùng kéo cột nguyên lên 200. Cột lẻ
//      lúc đó đứng yên nên `updateUIView` đẩy được nó về 0 ngay. Chiều này ổn.
//
//    • Kẹp lúc CHÍNH cột lẻ đang cuộn.  Đang ở 200, người dùng vuốt cột lẻ
//      sang 5. `updateUIView` CỐ Ý bỏ qua khi bánh xe còn kéo hoặc còn trôi
//      (đẩy lúc đó là giật ngay dưới ngón tay) — nên cú kẹp rơi vào khoảng
//      lặng: state nói 0, bánh xe dừng ở 5. Đúng cái cảnh mà
//      `externalChangeProbe` bên sheet nước uống dựng ra để xem.
//
//  Chỗ vá là MÉP SAU của chuyển động: `scrollViewDidEndDecelerating` và
//  `scrollViewDidEndDragging(willDecelerate:)` — thời điểm muộn nhất còn sửa
//  được. Xem `settle(_:)` trong `TableWheelColumn.Coordinator`.
//
//  Khác `updateUIView` ở một chi tiết cố ý: `settle` đẩy có ANIMATION. Đây là
//  một chỉnh sửa người dùng CẦN THẤY — bánh xe tự trườn về 0 chính là câu trả
//  lời cho "sao tôi chọn 200.5 mà không được".
//
//  ═══════════════════════════════════════════════════════════════════════════
//  3. PLINTH LÀ CỦA HÀNG, KHÔNG PHẢI CỦA CỘT
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Một plinth trải qua cột nguyên, dấu chấm, cột lẻ và cả chữ `kg`. Ở ca một
//  cột thì không nhận ra điều này vì plinth rộng đúng bằng cột.
//
//  Đây cũng là chỗ `Picker(.wheel)` hệ thống hết đường: SwiftUI `Picker` chỉ
//  có MỘT `selection` nên chỉ được một cột, muốn hai cột thì phải đặt hai
//  `Picker` cạnh nhau — và mỗi cái tự vẽ plinth riêng, thành hai plinth rời
//  không ghép được. Ca một cột còn "đủ dùng nếu chấp nhận trông như bánh xe
//  iOS chuẩn"; ca hai cột thì hỏng ngay ở hình.
//

import SwiftUI

struct WeightTableWheelSheet: View {
  /// Cân nặng tính bằng PHẦN MƯỜI kg — 600 là 60.0kg. Lý do ở khối 1 đầu file.
  @Binding var tenths: Int

  @Environment(\.dismiss) private var dismiss
  @State private var integerIndex: Int
  @State private var decimalIndex: Int

  static let integerRange = 30...200
  static let integerValues: [Int] = Array(integerRange)
  static let decimalValues: [Int] = Array(0...9)

  static var minTenths: Int { integerRange.lowerBound * 10 }

  /// Không phải `* 10 + 9`: chạm trần thì phần lẻ buộc về 0, nên 200.0 là hết.
  static var maxTenths: Int { integerRange.upperBound * 10 }

  /// Khởi tạo trong `init` chứ không phải `onAppear` — lý do đầy đủ ở
  /// `WaterGoalTableWheelSheet`.
  ///
  /// Ở đây không cần `nearestIndex` như mấy ca kia: lưới phần mười phủ KÍN mọi
  /// giá trị trong dải, nên chia lấy dư là ra đúng hàng, không có chuyện rơi
  /// giữa hai hàng. Chỉ cần kẹp về dải trước khi tách.
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

      TableWheelPairPicker(
        leadingValues: Self.integerValues.map { String($0) },
        leadingIndex: $integerIndex,
        trailingValues: Self.decimalValues.map { String($0) },
        trailingIndex: $decimalIndex,
        separator: ".",
        unitLabel: "kg"
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)
      // Hai chiều, vì ràng buộc bị phá được từ cả hai cột: kéo cột nguyên LÊN
      // 200 khi phần lẻ đang khác 0, hoặc đang ở 200 rồi kéo cột lẻ đi.
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

  /// Cột nguyên đang ở đỉnh dải — lúc đó phần lẻ chỉ được phép là 0.
  private var isAtCeiling: Bool {
    Self.integerValues[integerIndex] == Self.integerRange.upperBound
  }

  /// Điều kiện `decimalIndex != 0` không phải để tối ưu mà để KHÔNG lặp: gán
  /// vào `decimalIndex` lại kích hoạt chính `onChange` gọi hàm này.
  private func enforceCeiling() {
    guard isAtCeiling, decimalIndex != 0 else { return }
    decimalIndex = 0
  }
}
