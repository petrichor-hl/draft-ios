//
//  LearnAnimation.swift
//  Draft
//
//  Created by Lam Tran  on 14/7/26.
//
//  Menu các bài học về animation. Mỗi item dẫn tới một màn hình
//  tách riêng để mổ xẻ một kỹ thuật cụ thể.
//

import SwiftUI

struct LearnAnimation: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.swipeToConfirm)
      } label: {
        LabRow(title: "Swipe to Confirm",
               subtitle: "Kéo thumb qua ngưỡng để xác nhận — DragGesture + offset")
      }

      Button {
        coordinator.push(.kavsoftSlideToConfirm)
      } label: {
        LabRow(title: "Slide to Confirm (Kavsoft)",
               subtitle: "Dựng lại theo tutorial Kavsoft")
      }
    }
    .navigationTitle("Learn Animation")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
  let title: String
  let subtitle: String

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
    LearnAnimation()
      .environment(AppCoordinator())
  }
}
