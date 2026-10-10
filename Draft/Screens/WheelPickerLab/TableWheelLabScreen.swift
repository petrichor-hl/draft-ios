import SwiftUI

struct TableWheelLabScreen: View {
  @State private var waterGoalMl = 2500
  @State private var heightCm = 170
  @State private var birthYear = 1995
  /// Giá trị lưu là phần mười kg: 600 tương ứng 60.0 kg.
  @State private var weightTenths = 600
  @State private var eventDate = WheelDate(day: 11, month: 1, year: 2026)
  @State private var ageRange = 25...45
  @State private var presented: Sheet?
  @State private var sheetHeight: CGFloat = .zero

  private enum Sheet: String, Identifiable {
    case waterGoal, height, birthYear, weight, eventDate
    var id: String { rawValue }
  }

  var body: some View {
    List {
      Section("1 cột") {
        row("Mục tiêu nước uống", valueText: "\(waterGoalMl) ml") { presented = .waterGoal }
        row("Chiều cao", valueText: "\(heightCm) cm") { presented = .height }
        row("Năm sinh", valueText: String(birthYear)) { presented = .birthYear }
      }

      Section("2 cột") {
        row("Cân nặng", valueText: "\(weightTenths / 10).\(weightTenths % 10) kg") {
          presented = .weight
        }

        NavigationLink {
          AgeRangeTableWheelScreen(range: $ageRange)
        } label: {
          rowLabel("Khoảng tuổi", valueText: "\(ageRange.lowerBound) – \(ageRange.upperBound) tuổi")
        }
      }

      Section("3 cột") {
        row("Ngày sự kiện", valueText: eventDate.text) { presented = .eventDate }
      }
    }
    .navigationTitle("UITableView")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $presented) { sheet in
      sheetContent(sheet)
        .background { heightReader }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
  }

  /// Đo nội dung trong background để không thay đổi đề xuất kích thước.
  /// Sheet không dùng Spacer hoặc frame(maxHeight: .infinity).
  /// Không cộng safeAreaInsets.bottom: size.height đã bao gồm phần đó.
  private var heightReader: some View {
    GeometryReader { geometry in
      Color.clear
        .task { sheetHeight = geometry.size.height }
        .onChange(of: geometry.size.height) { _, newHeight in
          sheetHeight = newHeight
        }
    }
  }

  private func row(_ title: String, valueText: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      rowLabel(title, valueText: valueText)
    }
  }

  private func rowLabel(_ title: String, valueText: String) -> some View {
    HStack {
      Text(title)
        .foregroundStyle(.primary)
      Spacer()
      // Text(verbatim:) giữ nhãn số, không thêm dấu phân nhóm theo locale.
      Text(verbatim: valueText)
        .foregroundStyle(.secondary)
    }
  }

  @ViewBuilder
  private func sheetContent(_ sheet: Sheet) -> some View {
    switch sheet {
    case .waterGoal:
      WaterGoalTableWheelSheet(valueMl: $waterGoalMl)
    case .height:
      HeightTableWheelSheet(valueCm: $heightCm)
    case .birthYear:
      BirthYearTableWheelSheet(year: $birthYear)
    case .weight:
      WeightTableWheelSheet(tenths: $weightTenths)
    case .eventDate:
      EventDateTableWheelSheet(date: $eventDate)
    }
  }
}
