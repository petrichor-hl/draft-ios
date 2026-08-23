//
//  WheelPickerLabScreen.swift
//  Draft
//
//  Kho wheel picker. Bắt đầu bằng ca đơn giản nhất — MỘT cột, bước không đều,
//  có nhãn đơn vị. Hai cột (cân nặng) và ba cột (ngày sinh) làm sau, trên cùng
//  một component.
//
//  ⚠️ Component tự dựng ở đây CHỈ DÙNG API iOS 16. Draft ship iOS 26.5, nên rất
//     dễ lỡ tay dùng `scrollTargetBehavior` / `.scrollPosition` — những thứ
//     không tồn tại ở bản thấp và khiến cả kho không mang đi đâu được.
//

import SwiftUI

struct WheelPickerLabScreen: View {
  @State private var waterGoalMl = 2500
  @State private var heightCm = 170
  @State private var birthYear = 1995

  /// Cân nặng tính bằng PHẦN MƯỜI kg — 600 là 60.0kg. Lý do ở
  /// `WeightTableWheelSheet`.
  @State private var weightTenths = 600

  @State private var presented: Sheet?

  /// Chiều cao ĐO ĐƯỢC của sheet đang mở — xem `.sheet` ở cuối `body`.
  @State private var sheetHeight: CGFloat = .zero

  private enum Sheet: String, Identifiable {
    case systemPicker
    case tableWheel
    case collectionWheel
    case heightTable
    case heightCollection
    case birthYearTable
    case birthYearCollection
    case weightTable
    case weightCollection

    var id: String { rawValue }
  }

  var body: some View {
    List {
      Section {
        row("Picker(.wheel) hệ thống", value: waterGoalMl, unit: "ml") { presented = .systemPicker }
        row("UITableView tự dựng", value: waterGoalMl, unit: "ml") { presented = .tableWheel }
        row("UICollectionView tự dựng", value: waterGoalMl, unit: "ml") { presented = .collectionWheel }
      } header: {
        Text("1 cột — mục tiêu nước uống")
      } footer: {
        Text(
          """
          Bước 250ml, từ 2000 đến 6000. Hai hàng cùng một dữ liệu — mở lần lượt \
          rồi vuốt để so cảm giác cuộn, không chỉ so ảnh.
          """
        )
      }

      Section {
        row("UITableView tự dựng", value: heightCm, unit: "cm") { presented = .heightTable }
        row("UICollectionView tự dựng", value: heightCm, unit: "cm") { presented = .heightCollection }
      } header: {
        Text("1 cột — chiều cao")
      } footer: {
        Text(
          """
          Bước 1cm, từ 120 đến 220 — 101 hàng thay vì 17. Ca để xem việc tái \
          dùng cell có thật sự cần không: cuộn một mạch hết dải mà không giật \
          thì cả hai bản đang làm đúng việc.
          """
        )
      }

      Section {
        row("UITableView tự dựng", value: birthYear) { presented = .birthYearTable }
        row("UICollectionView tự dựng", value: birthYear) { presented = .birthYearCollection }
      } header: {
        Text("1 cột trần — năm sinh")
      } footer: {
        Text(
          """
          Không có nhãn đơn vị, chỉ còn cột số — chỗ nhìn rõ nhất phần nén \
          khoảng cách của bản collection. Cận trên là năm hiện tại, tính lúc \
          chạy chứ không viết cứng.
          """
        )
      }

      Section {
        row("UITableView tự dựng", valueText: weightText) { presented = .weightTable }
        row("UICollectionView tự dựng", valueText: weightText) { presented = .weightCollection }
      } header: {
        Text("2 cột — cân nặng")
      } footer: {
        Text(
          """
          Hai cột cuộn rời nhau dưới chung một plinth, nhưng CÓ ràng buộc: \
          chạm trần 200 thì phần lẻ bị kẹp về 0. Phần khó không nằm ở việc sửa \
          state mà ở chỗ bắt bánh xe đi theo khi cú kẹp rơi đúng lúc nó đang \
          trôi. Giá trị lưu là Int phần mười kg, không phải Double.
          """
        )
      }

      Section {
        Text("Ngày sinh — 3 cột phụ thuộc nhau")
      } header: {
        Text("Chưa làm")
      }
      .foregroundStyle(.tertiary)
    }
    .navigationTitle("Wheel Picker Toolbox")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $presented) { sheet in
      sheetContent(sheet)
        .background { heightReader }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
  }

  // MARK: - Views

  /// Thước đo chiều cao cho sheet — đặt trong `.background` của nội dung.
  ///
  /// `.presentationDetents` đòi một CON SỐ, mà con số đó chỉ biết sau khi
  /// layout xong. Gỡ nút thắt bằng cách đo rồi ném ngược vào detent:
  ///
  ///     nội dung tự chọn cỡ → GeometryReader đọc → sheetHeight → detent
  ///
  /// `.background` là chỗ đo đúng vì nó KHÔNG tham gia layout: nó không đề
  /// xuất kích thước gì cho nội dung, chỉ nhận lại đúng khung nội dung đã
  /// chọn. Đo bằng một `GeometryReader` bọc ngoài thì ngược lại — nó greedy,
  /// nuốt hết chỗ được đề xuất và trả về chính con số detent hiện tại.
  ///
  /// ⚠️ Vì lý do đó, nội dung sheet KHÔNG được chứa `Spacer` hay
  ///    `.frame(maxHeight: .infinity)`. Một `Spacer` là đủ để phép đo trả về
  ///    detent cũ thay vì chiều cao thật, và vòng lặp kẹt luôn ở đó.
  ///
  /// ⚠️ ĐỪNG cộng `safeAreaInsets.bottom` vào phép đo — dù nghe rất hợp lý.
  ///
  ///    ĐÃ ĐO (overlay tạm in size / safeAreaInsets.bottom / detent, chạy trên
  ///    iPhone 16 Pro iOS 18.6 và iPhone 17 iOS 26.5 — hai bản cho CÙNG một
  ///    bộ số):
  ///
  ///      sheet nước uống    size = 566.0     sa = 34.0   detent = 566.0
  ///      sheet năm sinh     size = 468.333…  sa = 34.0   detent = 468.333…
  ///
  ///    `size.height` LUÔN BẰNG detent: view nền trải hết chiều cao sheet, chứ
  ///    không dừng ở mép safe area. Nên `size + 34` không phải là "bù phần
  ///    thiếu" mà là cộng dồn: 566 → 600 → 634 → … Không có điểm dừng, và
  ///    sheet giật liên tục.
  ///
  ///    Phần nội dung thật sự dùng được vẫn chỉ là `detent − 34`. Ai gánh 34pt
  ///    đó? View CO GIÃN NHẤT. Vì vậy sheet nào có `Text` nhiều dòng thì cho nó
  ///    `.fixedSize(horizontal: false, vertical: true)` — xem
  ///    `externalChangeProbe` ở hai sheet nước uống. Chữa ở NỘI DUNG, đừng bơm
  ///    vào detent.
  ///
  /// `.task` bắt lần đầu; `.onChange` bắt các lần nội dung đổi cỡ sau đó —
  /// ở kho này là lúc đổi giữa các sheet cao thấp khác nhau.
  private var heightReader: some View {
    GeometryReader { geometry in
      Color.clear
        .task { sheetHeight = geometry.size.height }
        .onChange(of: geometry.size.height) { _, newHeight in
          sheetHeight = newHeight
        }
    }
  }

  /// Cân nặng ghép chuỗi thủ công từ canonical, không qua formatter số —
  /// cùng lý do locale với `Text(verbatim:)` ở `row`.
  private var weightText: String {
    "\(weightTenths / 10).\(weightTenths % 10) kg"
  }

  private func row(
    _ title: String,
    value: Int,
    unit: String = "",
    action: @escaping () -> Void
  ) -> some View {
    row(title, valueText: unit.isEmpty ? "\(value)" : "\(value) \(unit)", action: action)
  }

  private func row(
    _ title: String,
    valueText: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack {
        Text(title)
          .foregroundStyle(.primary)
        Spacer()
        // `Text(verbatim:)` chứ không nội suy: `Text("\(2500)")` bị format theo
        // locale và ra "2.500".
        Text(verbatim: valueText)
          .foregroundStyle(.secondary)
      }
    }
  }

  @ViewBuilder
  private func sheetContent(_ sheet: Sheet) -> some View {
    switch sheet {
    case .systemPicker:
      WaterGoalSystemPickerSheet(valueMl: $waterGoalMl)
    case .tableWheel:
      WaterGoalTableWheelSheet(valueMl: $waterGoalMl)
    case .collectionWheel:
      WaterGoalCollectionWheelSheet(valueMl: $waterGoalMl)
    case .heightTable:
      HeightTableWheelSheet(valueCm: $heightCm)
    case .heightCollection:
      HeightCollectionWheelSheet(valueCm: $heightCm)
    case .birthYearTable:
      BirthYearTableWheelSheet(year: $birthYear)
    case .birthYearCollection:
      BirthYearCollectionWheelSheet(year: $birthYear)
    case .weightTable:
      WeightTableWheelSheet(tenths: $weightTenths)
    case .weightCollection:
      WeightCollectionWheelSheet(tenths: $weightTenths)
    }
  }
}
