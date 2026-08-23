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
//  Bước 2 — bốn hàng nội dung.
//

import SwiftUI

struct FABSeparateDialogScreen: View {
  @State private var isOpen = false

  private let fabSize: CGFloat = 65
  private let panelWidth: CGFloat = 300
  private let panelCorner: CGFloat = 26
  private let rowIcon: CGFloat = 44

  // Lề của FAB, đo từ video bản gốc.
  private let fabTrailing: CGFloat = 30
  private let fabBottom: CGFloat = 50

  // Khoảng hở giữa đáy dialog và đỉnh FAB.
  private let gap: CGFloat = 16

  private let spring = Animation.spring(duration: 0.4, bounce: 0.4)

  /// Đóng nhanh hơn mở. Dùng .speed() thay vì khai một spring thứ hai để
  /// đường cong và độ nảy vẫn là một, chỉ khác tốc độ chạy — sửa `spring`
  /// là cả hai chiều đổi theo. 1.4 tương đương duration 0.4 → 0.29s.
  ///
  /// Cùng nguyên tắc với PressScaleStyle ở cuối file: mở/nhấn thì thong thả,
  /// đóng/nhả thì dứt khoát. Mở là lúc người dùng cần kịp thấy cái gì vừa
  /// hiện ra; đóng thì họ đã quyết xong rồi, kéo dài chỉ thành chờ đợi.
  private let closeSpeed: Double = 1.4

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
    VStack(spacing: 0) {
      row("Cân nặng", "55 kg", icons: ["scalemass.fill"])
      row("Vận động", "23 kcal", icons: ["dumbbell.fill"])
      row("Nước", "250 ml", icons: ["drop.fill"])
      row("Bữa ăn", "còn 1000 kcal", icons: ["keyboard.fill", "camera.fill"])
    }
    .padding(20)
    // Chỉ khoá bề ngang; chiều cao do nội dung quyết định. Làm được vì
    // scaleEffect chỉ phóng to KẾT QUẢ ĐÃ RENDER, không nội suy frame —
    // khác FABExpandScreen, nơi chiều cao chính là thứ đang được animate.
    // ZStack căn .bottomTrailing nên panel cao lên là nở LÊN TRÊN, đáy đứng yên.
    .frame(width: panelWidth)
    .background(
      RoundedRectangle(cornerRadius: panelCorner)
        .fill(Color(white: 0.11))
    )
    .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    .opacity(isOpen ? 1 : 0)
    .scaleEffect(isOpen ? 1 : 0.2, anchor: .bottomTrailing)
    .allowsHitTesting(isOpen)
    .padding(.trailing, fabTrailing)
    .padding(.bottom, fabBottom + fabSize + gap)
  }

  // Một hàng: tiêu đề + giá trị bên trái, một hoặc hai nút tròn bên phải.
  private func row(_ title: String, _ value: String, icons: [String]) -> some View {
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.white)
        Text(value)
          .font(.subheadline)
          .foregroundStyle(.white.opacity(0.55))
      }

      Spacer(minLength: 8)

      ForEach(icons, id: \.self) { name in
        Button {
          // Chưa nối hành động — màn này chỉ để mổ xẻ animation.
        } label: {
          Image(systemName: name)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: rowIcon, height: rowIcon)
            .background(Circle().fill(Color(white: 0.22)))
        }
        // Dùng lại đúng hiệu ứng nhấn của FAB cho nhất quán.
        .buttonStyle(PressScaleStyle())
      }
    }
    .padding(.vertical, 14)
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
    withAnimation(isOpen ? spring.speed(closeSpeed) : spring) {
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
  var pressIn: Animation = Animation.spring(duration: 0.2, bounce: 0)
  var pressOut: Animation = Animation.spring(duration: 0.12, bounce: 0.3)

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
