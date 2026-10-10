import SwiftUI

struct WheelPickerLabScreen: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button("Picker(.wheel) hệ thống") {
        coordinator.push(.systemWheelLab)
      }

      Button("UITableView") {
        coordinator.push(.tableWheelLab)
      }

      Button("UICollectionView") {
        coordinator.push(.collectionWheelLab)
      }
    }
    .navigationTitle("Wheel Picker Toolbox")
    .navigationBarTitleDisplayMode(.inline)
  }
}
