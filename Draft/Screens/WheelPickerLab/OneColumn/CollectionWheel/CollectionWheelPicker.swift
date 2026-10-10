import SwiftUI

enum CollectionWheelRendering {
  case overlaidLists
  case cellMasks
  case colorEffect
}

struct CollectionWheelPicker: View {
  var values: [String]
  @Binding var selectedIndex: Int
  /// Bỏ trống cho cột TRẦN (năm sinh chẳng hạn). Plinth vẫn vẽ, vì nó là
  /// vạch chỉ chỗ đang chọn chứ không phải nền cho chữ đơn vị.
  var unitLabel: String = ""
  var metrics: CollectionWheelMetrics = .default
  var rendering: CollectionWheelRendering = .overlaidLists

  @State private var scrollSync = OverlaidWheelScrollSync()

  var body: some View {
    ZStack {
      plinth
      switch rendering {
      case .overlaidLists:
        overlaidColumn(.unselected)
        overlaidColumn(.selected)
          .mask { plinth }
          .allowsHitTesting(false)
      case .cellMasks:
        CellMaskedCollectionWheelColumn(
          values: values,
          selectedIndex: $selectedIndex,
          metrics: metrics
        )
      case .colorEffect:
        ColorEffectCollectionWheelColumn(
          values: values,
          selectedIndex: $selectedIndex,
          metrics: metrics
        )
      }
    }
    .frame(height: metrics.height)
  }

  private var plinth: WheelPlinth {
    WheelPlinth(unitLabel: unitLabel, height: metrics.centerRowHeight)
  }

  private func overlaidColumn(_ appearance: OverlaidWheelAppearance) -> some View {
    OverlaidCollectionWheelColumn(
      values: values,
      selectedIndex: $selectedIndex,
      metrics: metrics,
      appearance: appearance,
      scrollSync: scrollSync
    )
  }
}
