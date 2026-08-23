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

  private let spring = Animation.spring(duration: 0.4, bounce: 0.4)

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

  // Ở đây KHÔNG dùng `if isOpen` + .transition, dù đó là cách "đúng bài" cho
  // chuyện view xuất hiện/biến mất. Đã thử hai biến thể, cả hai đều vướng.
  //
  // ❌ Biến thể 1 — .transition đặt TRƯỚC .padding:
  //
  //      @ViewBuilder
  //      private var dialog: some View {
  //        if isOpen {
  //          RoundedRectangle(cornerRadius: panelCorner)
  //            .fill(Color(white: 0.11))
  //            .frame(width: panelWidth, height: panelHeight)
  //            .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
  //            .transition(
  //              .scale(scale: 0.6, anchor: .bottomTrailing)
  //                .combined(with: .opacity)
  //            )
  //            .padding(.trailing, fabTrailing)
  //            .padding(.bottom, fabBottom + fabSize + gap)
  //        }
  //      }
  //
  //    Anchor thì đúng, nhưng animation CHỈ CHẠY MỘT CHIỀU. Đo bằng video
  //    (bề rộng vệt tối trên một dòng quét ngang qua thân dialog, px):
  //
  //      mở   : 792 → 828 → 860 → 866 → 862 → 857 → 852 → 850 → 849
  //      đóng : 849 → 0        (hai frame liền nhau, không giá trị trung gian)
  //
  //    Hỏng nửa vời như vậy khó phát hiện hơn hỏng hẳn — mở thì đẹp nên dễ
  //    tưởng là xong.
  //
  // ❌ Biến thể 2 — .transition đặt SAU .padding (đổi chỗ hai modifier trên):
  //
  //    Chiều đóng chạy lại được (đo: 900 → 715 → 0), nhưng ANCHOR SAI. Lúc này
  //    view mà transition ôm lấy đã bao gồm cả padding — mà padding dưới ở đây
  //    là fabBottom + fabSize + gap, tức kéo dài xuống tận đáy màn hình. Góc
  //    .bottomTrailing của cái khung đó nằm ở góc màn hình, ngay cạnh FAB, nên
  //    panel co về phía nút thay vì về góc của chính nó. Đưa .padding ra ngoài
  //    khối `if` cũng không cứu được: khung vẫn tính cả padding.
  //
  // ✅ Cách đang dùng — scaleEffect gắn THẲNG lên panel, TRƯỚC padding:
  //
  //    • anchor tính theo bounds của chính panel → góc dưới-phải của nó đứng
  //      yên khi phóng to, đúng như video mẫu
  //    • không phải transition mà chỉ là nội suy hai Double (scale và opacity)
  //      nên hai chiều chạy như nhau, không phụ thuộc việc SwiftUI có chịu giữ
  //      view lại trong lúc gỡ hay không
  //    • đổi lại: view luôn tồn tại trong cây, nên cần .allowsHitTesting(isOpen)
  //      để lúc ẩn nó không nuốt chạm của người dùng
  private var dialog: some View {
    RoundedRectangle(cornerRadius: panelCorner)
      .fill(Color(white: 0.11))
      .frame(width: panelWidth, height: panelHeight)
      .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
      .scaleEffect(isOpen ? 1 : 0.3, anchor: .bottomTrailing)
      .opacity(isOpen ? 1 : 0)
      .allowsHitTesting(isOpen)
      .padding(.trailing, fabTrailing)
      .padding(.bottom, fabBottom + fabSize + gap)
  }

  // MARK: - FAB đứng yên, chỉ xoay dấu +

  private var fabButton: some View {
    // Button chứ không phải .onTapGesture: chỉ Button mới có trạng thái
    // isPressed để làm hiệu ứng nhấn lún.
    Button {
      toggle()
    } label: {
      Circle()
        .fill(Color(white: 0.11))
        .frame(width: fabSize, height: fabSize)
        .overlay {
          // + xoay 45° thành ×. Không đổi icon, không crossfade — chỉ là một
          // Angle chạy từ 0 tới 45, nên nó nảy theo đúng spring bên trên.
          Image(systemName: "plus")
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .rotationEffect(.degrees(isOpen ? 225 : 0))
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
    }
    .buttonStyle(PressScaleStyle())
    .padding(.trailing, fabTrailing)
    .padding(.bottom, fabBottom)
  }

  private func toggle() {
    withAnimation(spring) {
      isOpen.toggle()
    }
  }

  // MARK: -

  private var caption: some View {
    Text("Dialog là view riêng, bật ra bằng transition scale(anchor: .bottomTrailing).\nFAB đứng yên, dấu + xoay 225° thành ×.")
      .font(.caption)
      .foregroundStyle(.secondary)
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

// MARK: - Hiệu ứng nhấn lún

struct PressScaleStyle: ButtonStyle {
  var pressedScale: CGFloat = 0.8
  var pressIn: Animation = .spring(duration: 0.2, bounce: 0)
  var pressOut: Animation = .spring(duration: 0.12, bounce: 0.3)

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? pressedScale : 1)
      .animation(configuration.isPressed ? pressIn : pressOut,
                 value: configuration.isPressed)
  }
}

#Preview {
  NavigationStack {
    FABSeparateDialogScreen()
  }
}
