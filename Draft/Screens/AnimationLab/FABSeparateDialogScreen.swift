//
//  FABSeparateDialogScreen.swift
//  Draft
//
//  Biến thể của FABExpandScreen: dialog TÁCH RỜI khỏi FAB.
//
//  Khác chỗ nào:
//    • FABExpandScreen — một khối duy nhất, nút tròn phình thành dialog.
//    • màn này        — hai view riêng. FAB đứng yên và chỉ xoay dấu +
//                       thành ×; dialog bật ra phía trên nó.
//
//  Bước 1 — dialog rỗng, chưa có nút bên trong.
//

import SwiftUI

struct FABSeparateDialogScreen: View {
  @State private var isOpen = false

  private let fabSize: CGFloat = 65
  private let panelWidth: CGFloat = 300
  private let panelHeight: CGFloat = 345
  private let panelCorner: CGFloat = 26

  // Lề của FAB, đo từ video bản gốc.
  private let fabTrailing: CGFloat = 30
  private let fabBottom: CGFloat = 50

  // Khoảng hở giữa đáy dialog và đỉnh FAB.
  private let gap: CGFloat = 16

  private let spring = Animation.spring(duration: 0.3, bounce: 0.4)

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Color.black
        .opacity(isOpen ? 0.2 : 0)
        .ignoresSafeArea()
        .allowsHitTesting(isOpen)
        .onTapGesture { toggle() }

      dialog
      fabButton
      caption
    }
    .navigationTitle("FAB + Dialog tách rời")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Dialog: view riêng, không dính gì tới FAB

  @ViewBuilder
  private var dialog: some View {
    if isOpen {
      RoundedRectangle(cornerRadius: panelCorner)
        .fill(Color(white: 0.11))
        .frame(width: panelWidth, height: panelHeight)
        .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
        .padding(.trailing, fabTrailing)
        .padding(.bottom, fabBottom + fabSize + gap)
        // THỨ TỰ QUAN TRỌNG: .transition phải nằm NGOÀI CÙNG, sau .padding.
        //
        // Đặt nó TRƯỚC hai .padding thì animation chỉ chạy một chiều — mở
        // thì đẹp, đóng thì tắt phụt. Đo trên video (bề rộng vệt tối trên
        // một dòng quét ngang qua thân dialog, px):
        // anchor: .bottomTrailing làm nó "mọc lên từ nút" thay vì phình từ tâm.
        .transition(
          .scale(scale: 0.6, anchor: .bottomTrailing)
            .combined(with: .opacity)
        )
    }
  }

  // MARK: - FAB đứng yên, chỉ xoay dấu +

  private var fabButton: some View {
    Circle()
      .fill(Color(white: 0.11))
      .frame(width: fabSize, height: fabSize)
      .overlay {
        // + xoay 45° thành ×. Không đổi icon, không crossfade — chỉ là một
        // Angle chạy từ 0 tới 45, nên nó nảy theo đúng spring bên trên.
        Image(systemName: "plus")
          .font(.title2.weight(.semibold))
          .foregroundStyle(.white)
          .rotationEffect(.degrees(isOpen ? 45 : 0))
      }
      .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
      .padding(.trailing, fabTrailing)
      .padding(.bottom, fabBottom)
      .onTapGesture { toggle() }
  }

  private func toggle() {
    withAnimation(spring) {
      isOpen.toggle()
    }
  }

  // MARK: -

  private var caption: some View {
    Text("Dialog là view riêng, bật ra bằng transition scale(anchor: .bottomTrailing).\nFAB đứng yên, dấu + xoay 45° thành ×.")
      .font(.caption)
      .foregroundStyle(.secondary)
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    FABSeparateDialogScreen()
  }
}
