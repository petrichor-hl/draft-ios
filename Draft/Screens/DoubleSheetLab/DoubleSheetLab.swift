//
//  DoubleSheetLab.swift
//  Draft
//
//  Chuyện gì xảy ra khi một View gắn 2 .sheet() và ta cố show cái thứ hai
//  trong lúc cái thứ nhất đang present?
//
//  Ba màn: hai cách gắn sai/hên xui, rồi tới cách đúng.
//

import SwiftUI

struct DoubleSheetLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.doubleSheetChained)
      } label: {
        DoubleSheetLabRow(
          title: "1. Hai .sheet chồng lên cùng một view",
          subtitle: "Đúng trường hợp cần test — sheet thứ hai đi đâu?"
        )
      }

      Button {
        coordinator.push(.doubleSheetSibling)
      } label: {
        DoubleSheetLabRow(
          title: "2. Hai .sheet ở hai view anh em",
          subtitle: "Khác anchor thì có thoát được không?"
        )
      }

      Button {
        coordinator.push(.doubleSheetItem)
      } label: {
        DoubleSheetLabRow(
          title: "3. Một .sheet(item:) duy nhất",
          subtitle: "Cách đúng — enum quyết định sheet nào đang mở"
        )
      }

      Button {
        coordinator.push(.doubleCover)
      } label: {
        DoubleSheetLabRow(
          title: "4. Hai .fullScreenCover",
          subtitle: "Cover có đi chung cửa với sheet không?"
        )
      }

      Button {
        coordinator.push(.sheetAndCover)
      } label: {
        DoubleSheetLabRow(
          title: "5. Một .sheet + một .fullScreenCover",
          subtitle: "Hai loại khác nhau có thành hai kênh độc lập?"
        )
      }

      Button {
        coordinator.push(.coverAndSheetReversed)
      } label: {
        DoubleSheetLabRow(
          title: "6. Đảo thứ tự: cover trước, sheet sau",
          subtitle: "Thứ tự modifier hay loại presentation mới quyết định?"
        )
      }
    }
    .navigationTitle("Double Sheet Lab")
  }
}

private struct DoubleSheetLabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    DoubleSheetLab()
      .environment(AppCoordinator())
  }
}
