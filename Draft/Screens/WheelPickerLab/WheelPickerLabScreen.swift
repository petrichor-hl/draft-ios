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
  @State private var presented: Sheet?

  private enum Sheet: String, Identifiable {
    case systemPicker
    case tableWheel
    case collectionWheel

    var id: String { rawValue }
  }

  var body: some View {
    List {
      Section {
        row("Picker(.wheel) hệ thống", value: waterGoalMl) { presented = .systemPicker }
        row("UITableView tự dựng", value: waterGoalMl) { presented = .tableWheel }
        row("UICollectionView tự dựng", value: waterGoalMl) { presented = .collectionWheel }
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
        Text("Cân nặng — 2 cột (nguyên . thập phân)")
        Text("Ngày sinh — 3 cột phụ thuộc nhau")
        Text("Chiều cao — 1 cột, cm")
        Text("Năm sinh — 1 cột trần")
      } header: {
        Text("Chưa làm")
      }
      .foregroundStyle(.tertiary)
    }
    .navigationTitle("Wheel Picker Toolbox")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $presented) { sheet in
      sheetContent(sheet)
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
  }

  // MARK: - Views

  private func row(
    _ title: String,
    value: Int,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack {
        Text(title)
          .foregroundStyle(.primary)
        Spacer()
        // `Text(verbatim:)` chứ không nội suy: `Text("\(2500)")` bị format theo
        // locale và ra "2.500".
        Text(verbatim: "\(value) ml")
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
    }
  }
}
