//
//  FABExpandScreen.swift
//  Draft
//
//  Clone hiệu ứng FAB phình thành dialog (bản gốc: app BitePal).
//
//  Ý chính: KHÔNG phải nút biến mất rồi dialog hiện ra. Chỉ có MỘT khối,
//  đổi kích thước và bo góc. Nút tròn chính là dialog lúc còn nhỏ.
//
//  Mọi con số dưới đây đo từ video quay màn hình bản gốc (884x1920 @60fps,
//  quy về point với tỉ lệ 2.2):
//
//    • spring: vọt qua đích 5.8% quãng đường khi mở, 6.0% khi đóng
//      → damping ratio 0.67 → bounce 0.33
//      đỉnh vọt cách lúc bắt đầu 0.291s → duration 0.42s
//    • FAB 65x65pt, cách mép phải 30pt, cách đáy 50pt
//    • dialog 283x345pt, bo góc 26pt, cách mép phải 15pt, cách đáy 36pt
//
//  Bước 1 — dialog rỗng, chưa có nút bên trong.
//

import SwiftUI

struct FABExpandScreen: View {
  @State private var isOpen = false

  private let fabSize: CGFloat = 65
  private let panelWidth: CGFloat = 300
  private let panelHeight: CGFloat = 345
  private let panelCorner: CGFloat = 26

  // Bản gốc neo FAB và dialog ở hai chỗ hơi khác nhau: FAB thụt vào
  // thêm ~15pt so với dialog ở cả hai cạnh. Nên trong lúc phình, góc
  // dưới-phải cũng dịch ra một chút chứ không đứng yên.
  private let inset: CGFloat = 15

  private let spring = Animation.spring(duration: 0.42, bounce: 0.33)

  var body: some View {
    ZStack(alignment: .bottomTrailing) {

      if isOpen {
        Color.black.opacity(0.2)
          .ignoresSafeArea()
          .transition(.opacity)
          .onTapGesture { toggle() }
      }

      morphingBlock
        .padding(.trailing, 15)
        .padding(.bottom, 36)

      caption
    }
    .navigationTitle("FAB → Dialog")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Khối morph

  private var morphingBlock: some View {
    ZStack {
      // Bo góc chạy từ 32.5 (đúng nửa cạnh = hình tròn) xuống 26.
      RoundedRectangle(cornerRadius: isOpen ? panelCorner : fabSize / 2)
        .fill(Color(white: 0.11))

      Image(systemName: "plus")
        .font(.title2.weight(.semibold))
        .foregroundStyle(.white)
        .opacity(isOpen ? 0 : 1)
    }
    // ① width/height là CGFloat nên nội suy được; ZStack cha căn
    //    .bottomTrailing nên khối lớn ra theo hướng lên-trái.
    .frame(
      width: isOpen ? panelWidth : fabSize,
      height: isOpen ? panelHeight : fabSize
    )
    // ② bù phần FAB thụt vào so với dialog.
    .offset(
      x: isOpen ? 0 : -inset,
      y: isOpen ? 0 : -inset
    )
    .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    .contentShape(Rectangle())
    .onTapGesture { toggle() }
  }

  private func toggle() {
    withAnimation(spring) {
      isOpen.toggle()
    }
  }

  // MARK: -

  private var caption: some View {
    Text("spring(duration: 0.42, bounce: 0.33)\nĐo từ video gốc — vọt qua đích 5.8% quãng đường.")
      .font(.caption)
      .foregroundStyle(.secondary)
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  NavigationStack {
    FABExpandScreen()
  }
}
