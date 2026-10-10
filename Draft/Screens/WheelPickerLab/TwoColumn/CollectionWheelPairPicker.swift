//
//  CollectionWheelPairPicker.swift
//  Draft
//
//  Hai cột `OverlaidCollectionWheelColumn` dưới chung một plinth.
//
//  Nằm cạnh `TableWheelPairPicker` trong `TwoColumn/` vì cùng một lý do: thư
//  mục chia theo SỐ CỘT, và cách xếp hai cột thì giống nhau ở cả hai cách
//  dựng. Xem ghi chú đầy đủ ở file đó.
//

import SwiftUI

/// Bản collection của `TableWheelPairPicker` — lý do "hai scroll view chứ không
/// phải một layout hai cột" nằm ở đó, không chép lại.
///
/// Ở đây có thêm một điều ca một cột không thấy được: phần NÉN KHOẢNG CÁCH của
/// bản collection chạy độc lập cho từng cột, nên hai cột cùng cong theo cùng
/// một hình trụ dù chúng chẳng biết gì về nhau. Đặt cạnh bản table để xem cái
/// cong đó có đáng hay không.
struct CollectionWheelPairPicker: View {
  var leadingValues: [String]
  @Binding var leadingIndex: Int
  var trailingValues: [String]
  @Binding var trailingIndex: Int

  var separator: String
  var unitLabel: String = ""

  /// Hai bề rộng khác nhau — xem `TableWheelPairPicker`.
  var leadingWidth: CGFloat = 100
  var trailingWidth: CGFloat = 60
  var separatorWidth: CGFloat = 24

  var metrics: CollectionWheelMetrics = .default

  @State private var leadingScrollSync = OverlaidWheelScrollSync()
  @State private var trailingScrollSync = OverlaidWheelScrollSync()

  var body: some View {
    ZStack {
      plinth
      overlaidColumns(.unselected)
      overlaidColumns(.selected)
        .mask { plinth }
        .allowsHitTesting(false)
    }
    .frame(height: metrics.height)
  }

  private var plinth: WheelPlinth {
    WheelPlinth(unitLabel: unitLabel, height: metrics.centerRowHeight)
  }

  private func overlaidColumns(_ appearance: OverlaidWheelAppearance) -> some View {
    HStack(spacing: 0) {
      OverlaidCollectionWheelColumn(
        values: leadingValues,
        selectedIndex: $leadingIndex,
        metrics: metrics,
        appearance: appearance,
        scrollSync: leadingScrollSync
      )
      .frame(width: leadingWidth)

      Text(separator)
        .font(.system(size: metrics.fontSize, weight: .bold))
        .foregroundStyle(appearance == .unselected ? Color.gray : Color.primary)
        .frame(width: separatorWidth)

      OverlaidCollectionWheelColumn(
        values: trailingValues,
        selectedIndex: $trailingIndex,
        metrics: metrics,
        appearance: appearance,
        scrollSync: trailingScrollSync
      )
      .frame(width: trailingWidth)
    }
    .frame(maxWidth: .infinity)
  }
}
