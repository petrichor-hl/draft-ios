import SwiftUI

struct SystemWheelLabScreen: View {
  @State private var waterGoalMl = 2500
  @State private var isPresented = false
  @State private var sheetHeight: CGFloat = .zero

  var body: some View {
    List {
      Section("1 cột") {
        Button {
          isPresented = true
        } label: {
          HStack {
            Text("Mục tiêu nước uống")
              .foregroundStyle(.primary)
            Spacer()
            Text(verbatim: "\(waterGoalMl) ml")
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .navigationTitle("Picker(.wheel) hệ thống")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isPresented) {
      WaterGoalSystemPickerSheet(valueMl: $waterGoalMl)
        .background { heightReader }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
  }

  private var heightReader: some View {
    GeometryReader { geometry in
      Color.clear
        .task { sheetHeight = geometry.size.height }
        .onChange(of: geometry.size.height) { _, newHeight in
          sheetHeight = newHeight
        }
    }
  }
}
