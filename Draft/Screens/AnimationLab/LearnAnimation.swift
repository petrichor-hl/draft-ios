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
      Section {
        Button {
          coordinator.push(.animationBasics)
        } label: {
          LabRow(title: "1. Basics ⭐️",
                 subtitle: "withAnimation vs .animation(value:) — animate GIÁ TRỊ")
        }

        Button {
          coordinator.push(.animationCurves)
        } label: {
          LabRow(title: "2. Curves",
                 subtitle: "ease/spring chạy đua song song + delay, repeat, speed")
        }

        Button {
          coordinator.push(.animationTransitions)
        } label: {
          LabRow(title: "3. Transitions",
                 subtitle: "View xuất hiện/biến mất + contentTransition")
        }

        Button {
          coordinator.push(.animationPhaseKeyframe)
        } label: {
          LabRow(title: "4. Phase & Keyframe",
                 subtitle: "Animation nhiều chặng, iOS 17+")
        }
      } header: {
        Text("Nền tảng")
      } footer: {
        Text("Đi theo thứ tự 1 → 4. Mỗi màn có phần footer giải thích ngay dưới demo.")
      }

      Section {
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
      } header: {
        Text("Thực hành")
      }
    }
    .navigationTitle("Learn Animation")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
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
    LearnAnimation()
      .environment(AppCoordinator())
  }
}
