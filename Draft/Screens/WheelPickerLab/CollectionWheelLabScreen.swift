import SwiftUI

struct CollectionWheelLabScreen: View {
  @State private var waterGoalMl = 2500
  @State private var heightCm = 170
  @State private var birthYear = 1995
  /// Giá trị lưu là phần mười kg: 600 tương ứng 60.0 kg.
  @State private var weightTenths = 600
  @State private var eventDate = WheelDate(day: 11, month: 1, year: 2026)
  @State private var ageRange = 25...45
  @State private var rendering: CollectionWheelRendering = .overlaidLists
  @State private var presented: Sheet?
  @State private var sheetHeight: CGFloat = .zero

  private enum Sheet: String, Identifiable {
    case waterGoal, height, birthYear, weight, eventDate
    var id: String { rawValue }
  }

  var body: some View {
    List {
      Section("Cách tiếp cận") {
        Picker("Cách dựng", selection: $rendering) {
          Text("OverlaidList").tag(CollectionWheelRendering.overlaidLists)
          Text("CellMasks").tag(CollectionWheelRendering.cellMasks)
          Text("ColorEffect").tag(CollectionWheelRendering.colorEffect)
        }
        .pickerStyle(.segmented)
      }

      Section("1 cột") {
        row("Mục tiêu nước uống", valueText: "\(waterGoalMl) ml") { presented = .waterGoal }
        row("Chiều cao", valueText: "\(heightCm) cm") { presented = .height }
        row("Năm sinh", valueText: String(birthYear)) { presented = .birthYear }
      }

      Section("2 cột — OverlaidList") {
        row("Cân nặng", valueText: "\(weightTenths / 10).\(weightTenths % 10) kg") {
          presented = .weight
        }

        NavigationLink {
          AgeRangeCollectionWheelScreen(range: $ageRange)
        } label: {
          rowLabel("Khoảng tuổi", valueText: "\(ageRange.lowerBound) – \(ageRange.upperBound) tuổi")
        }
      }

      Section("3 cột — OverlaidList") {
        row("Ngày sự kiện", valueText: eventDate.text) { presented = .eventDate }
      }
    }
    .navigationTitle("UICollectionView")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $presented) { sheet in
      sheetContent(sheet)
        .background { heightReader }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
  }

  /// Đo chiều cao sheet theo nội dung, cùng cách với TableWheelLabScreen.
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
      Text(verbatim: valueText)
        .foregroundStyle(.secondary)
    }
  }

  @ViewBuilder
  private func sheetContent(_ sheet: Sheet) -> some View {
    switch sheet {
    case .waterGoal:
      WaterGoalCollectionWheelSheet(valueMl: $waterGoalMl, rendering: rendering)
    case .height:
      HeightCollectionWheelSheet(valueCm: $heightCm, rendering: rendering)
    case .birthYear:
      BirthYearCollectionWheelSheet(year: $birthYear, rendering: rendering)
    case .weight:
      WeightCollectionWheelSheet(tenths: $weightTenths)
    case .eventDate:
      EventDateCollectionWheelSheet(date: $eventDate)
    }
  }
}
