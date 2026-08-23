//
//  WaterGoalCollectionWheelSheet.swift
//  Draft
//
//  Cùng một sheet như `WaterGoalSystemPickerSheet`, nhưng dựng bằng
//  `CollectionWheelPicker` (UICollectionView + custom layout) — bản duy nhất
//  nén được KHOẢNG CÁCH giữa các hàng, không chỉ cỡ chữ.
//
//  Hai file để cạnh nhau là cố ý: mở lần lượt trong lab rồi so trực tiếp bằng
//  ngón tay — hình thì nhìn ảnh là biết, còn cảm giác cuộn thì chỉ vuốt mới biết.
//

import SwiftUI

struct WaterGoalCollectionWheelSheet: View {
  @Binding var valueMl: Int

  @Environment(\.dismiss) private var dismiss
  @State private var selectedIndex: Int

  static let step = 250
  static let range = 2000...6000

  static let values: [Int] = Array(
    stride(from: range.lowerBound, through: range.upperBound, by: step)
  )

  /// Khởi tạo trong `init`, không phải `onAppear`.
  ///
  /// `onAppear` chạy SAU lần render đầu, nên bánh xe dựng ở hàng 0 rồi mới nhảy
  /// về đúng chỗ. `Picker` nhảy đủ nhanh để không thấy; bánh xe tự dựng thì cú
  /// nhảy đó rơi đúng lúc sheet đang trượt lên nên lộ ra.
  ///
  /// `State(initialValue:)` chỉ ăn ở lần dựng đầu của một view identity — các
  /// lần SwiftUI dựng lại struct sau đó đều bỏ qua, nên không có chuyện nó ghi
  /// đè vị trí người dùng vừa cuộn tới.
  init(valueMl: Binding<Int>) {
    self._valueMl = valueMl
    self._selectedIndex = State(initialValue: Self.nearestIndex(to: valueMl.wrappedValue))
  }

  var body: some View {
    VStack(spacing: 0) {
      Text("Điều chỉnh mục tiêu nước uống")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      CollectionWheelPicker(
        values: Self.values.map { String($0) },
        selectedIndex: $selectedIndex,
        unitLabel: "ml"
      )
      .padding(.horizontal, 24)
      .padding(.vertical, 24)

      externalChangeProbe
        .padding(.bottom, 24)

      Button {
        valueMl = Self.values[selectedIndex]
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
    }
  }

  /// Ba nút đổi `selectedIndex` từ phía SwiftUI, không đụng gì tới bánh xe.
  ///
  /// Đây là cách nhìn thấy chiều **ĐI VÀO** của `@Binding`:
  ///
  ///     ĐI RA   người dùng cuộn → Coordinator ghi selectedIndex
  ///     ĐI VÀO  code đổi selectedIndex → updateUIView kéo bánh xe theo
  ///
  /// Chiều đi ra do `Coordinator` lo, chiều đi vào do `updateUIView` lo.
  ///
  /// **Cách thử:** comment dòng `table.setContentOffset(...)` trong
  /// `updateUIView` rồi bấm mấy nút này — bánh xe sẽ ĐỨNG IM trong khi nút
  /// "Cập nhật" vẫn lưu giá trị mới. State và UI nói hai chuyện khác nhau.
  ///
  /// Không phải chuyện lý thuyết: cột ngày sinh phải kẹp `dayIndex` khi tháng
  /// đổi (31/01 → tháng 02), và nếu bánh xe không đi theo thì lần cuộn kế tiếp
  /// đọc `values[30]` trên mảng 29 phần tử → crash.
  private var externalChangeProbe: some View {
    VStack(spacing: 8) {
      Text("DEBUG — thử updateUIView")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(.secondary)

      Text("Ba nút này đổi selectedIndex từ SwiftUI. Bánh xe phải tự trượt theo — đó là chiều \"đi vào\" do updateUIView lo.")
        .font(.system(size: 11))
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
        // Sheet cao theo detent, mà detent lại đo từ chính nội dung này —
        // xem `heightReader` ở `WheelPickerLabScreen`. Nội dung luôn hụt đúng
        // phần safe area đáy, và view CO GIÃN NHẤT gánh chỗ hụt: không có
        // `fixedSize` thì đoạn này rút 2 dòng xuống 1 dòng có "…".
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: 12) {
        probeButton("Min") { selectedIndex = 0 }
        probeButton("Giữa") { selectedIndex = Self.values.count / 2 }
        probeButton("Max") { selectedIndex = Self.values.count - 1 }
      }
      .padding(.top, 4)
    }
    .padding(.horizontal, 24)
  }

  private func probeButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 15, weight: .medium))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemBackground), in: .capsule)
    }
    .buttonStyle(.plain)
  }

  /// Giá trị đang lưu có thể không nằm trên lưới (2600 chẳng hạn) — bắt về hàng
  /// gần nhất thay vì rơi về đầu danh sách.
  ///
  /// Quét O(n) chứ không tính thẳng `(value − lower) / step`, để lưới không đều
  /// sau này cũng dùng được hàm này.
  ///
  /// ⚠️ Hoà thì làm tròn XUỐNG: 2125 cách 2000 và 2250 đúng 125 như nhau,
  ///    predicate trả `false` cả hai chiều nên `min` giữ phần tử gặp trước.
  private static func nearestIndex(to value: Int) -> Int {
    values.enumerated()
      .min { abs($0.element - value) < abs($1.element - value) }?
      .offset ?? 0
  }
}
