//
//  StepSlider.swift
//  Draft
//
//  Thanh kéo theo mốc: 0 · 25 · 50 · 75 · 100. Thumb nhảy hẳn sang mốc gần
//  nhất ngay trong lúc kéo, không bao giờ đứng ở giữa hai mốc.
//
//  Snap bỏ luôn được `anchor` của `VolumeSlider`. Ở đó mốc-lúc-bắt-đầu cộng
//  translation là để giá trị không giật khi cầm lệch tâm thumb; ở đây vị trí
//  ngón tay quyết định tất cả, vì kết quả còn phải đi qua một phép làm tròn về
//  mốc — lệch vài pt không đổi được gì. Một `gesture.location.x` là đủ.
//
//  Mốc KHÔNG bắt buộc cách đều: vị trí tính theo GIÁ TRỊ, và snap tìm mốc gần
//  nhất theo giá trị chứ không theo pixel. Đưa vào [0, 10, 50, 100] thì bốn
//  chấm nằm đúng chỗ của chúng trên thang, thưa nhặt khác nhau.
//

import SwiftUI

struct StepSlider: View {
  @Binding var value: Int

  /// Các mốc, tăng dần. Mốc đầu và mốc cuối là hai đầu thang.
  let steps: [Int]

  @State private var isDragging = false

  private static let trackHeight: CGFloat = 16
  private static let thumbSize: CGFloat = 32
  private static let tickSize: CGFloat = 8
  /// Khoảng hở giữa thumb và hai mảnh track — thứ làm thumb trông như được
  /// khoét chỗ chứ không phải đặt đè lên.
  private static let notch: CGFloat = 5
  private static let bubbleWidth: CGFloat = 56
  private static let bubbleHeight: CGFloat = 40
  private static let tailHeight: CGFloat = 8
  private static let bubbleGap: CGFloat = 6

  private var lower: Int { steps.first ?? 0 }
  private var upper: Int { steps.last ?? 100 }

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width
      let travel = max(width - Self.thumbSize, 1)
      let thumbX = travel * fraction(of: value)

      ZStack(alignment: .leading) {
        // Track là HAI mảnh rời chứ không phải một thanh bị thumb che: mảnh
        // trái dừng trước thumb, mảnh phải bắt đầu sau thumb, mỗi mảnh là một
        // Capsule nên hai đầu quay vào thumb tự bo tròn.
        Capsule()
          .fill(Color.accentColor)
          .frame(width: max(thumbX - Self.notch, 0), height: Self.trackHeight)

        Capsule()
          .fill(Color.gray.s200)
          .frame(
            width: max(width - thumbX - Self.thumbSize - Self.notch, 0),
            height: Self.trackHeight
          )
          .offset(x: thumbX + Self.thumbSize + Self.notch)

        ticks(travel: travel, thumbX: thumbX)

        thumb.offset(x: thumbX)
      }
      .frame(height: Self.thumbSize)
      // Giá trị nhảy từng nấc nên cú dịch chuyển phải có animation, khác
      // `VolumeSlider` nơi thumb bám ngón tay từng frame và mọi animation đều
      // thành độ trễ.
      .animation(.snappy(duration: 0.18), value: value)
      .gesture(drag(travel: travel))
    }
    .frame(height: Self.thumbSize)
    .sensoryFeedback(.selection, trigger: value)
  }

  // MARK: - Views

  private var thumb: some View {
    Circle()
      .fill(Color.accentColor)
      .frame(width: Self.thumbSize, height: Self.thumbSize)
      // Nhãn treo vào thumb, cùng cách đã chốt ở `VolumeSlider`.
      .overlay(alignment: .top) {
        bubble.offset(y: -(Self.bubbleHeight + Self.bubbleGap))
      }
  }

  private var bubble: some View {
    Text(verbatim: "\(value)")
      .font(.headline)
      .monospacedDigit()
      .foregroundStyle(Color(.systemBackground))
      .frame(width: Self.bubbleWidth, height: Self.bubbleHeight - Self.tailHeight)
      // Phần đệm này là chỗ của cái đuôi: chữ vẫn căn giữa thân bóng, còn
      // `BubbleShape` nhận đủ chiều cao để vẽ thêm tam giác bên dưới.
      .padding(.bottom, Self.tailHeight)
      .background(BubbleShape(tailHeight: Self.tailHeight).fill(Color.primary))
      .opacity(isDragging ? 1 : 0)
      .scaleEffect(isDragging ? 1 : 0.7, anchor: .bottom)
      .animation(.snappy(duration: 0.2), value: isDragging)
  }

  private func ticks(travel: CGFloat, thumbX: CGFloat) -> some View {
    let thumbCenter = thumbX + Self.thumbSize / 2

    return ForEach(steps, id: \.self) { step in
      let center = Self.thumbSize / 2 + travel * fraction(of: step)

      // Chấm nằm dưới thumb hoặc rơi vào khoảng hở thì không vẽ. Bỏ điều kiện
      // này thì ở khoảng hở còn lại một chấm trắng lơ lửng trên nền — sáng
      // không thấy vì nền cũng trắng, tối là lòi ngay.
      if abs(center - thumbCenter) > Self.thumbSize / 2 + Self.notch {
        Circle()
          .fill(Color(.systemBackground))
          .frame(width: Self.tickSize, height: Self.tickSize)
          .offset(x: center - Self.tickSize / 2)
      }
    }
  }

  // MARK: - Kéo

  private func drag(travel: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        isDragging = true
        value = nearestStep(atX: gesture.location.x, travel: travel)
      }
      .onEnded { _ in isDragging = false }
  }

  // MARK: - Toạ độ

  private func fraction(of value: Int) -> CGFloat {
    let span = CGFloat(upper - lower)
    guard span > 0 else { return 0 }
    return CGFloat(value - lower) / span
  }

  /// Đổi toạ độ chạm về giá trị thô rồi tìm mốc gần nhất THEO GIÁ TRỊ. Trừ nửa
  /// thumb vì quãng thumb đi được là `width − thumbSize`, cùng lý do như
  /// `VolumeSlider`.
  private func nearestStep(atX x: CGFloat, travel: CGFloat) -> Int {
    let raw = Double(lower) + Double((x - Self.thumbSize / 2) / travel) * Double(upper - lower)
    return steps.min { abs(Double($0) - raw) < abs(Double($1) - raw) } ?? value
  }
}

/// Bóng thoại: thân bo góc ở trên, tam giác nhọn chỉ xuống ở dưới.
///
/// `rect` nhận được là TOÀN BỘ khung, gồm cả phần đệm dưới — nên thân bóng
/// phải tự trừ `tailHeight` ra, không thì tam giác vẽ đè lên chính nó.
private struct BubbleShape: Shape {
  var cornerRadius: CGFloat = 10
  var tailWidth: CGFloat = 14
  var tailHeight: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path(
      roundedRect: CGRect(
        x: rect.minX,
        y: rect.minY,
        width: rect.width,
        height: rect.height - tailHeight
      ),
      cornerRadius: cornerRadius
    )

    path.move(to: CGPoint(x: rect.midX - tailWidth / 2, y: rect.maxY - tailHeight))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX + tailWidth / 2, y: rect.maxY - tailHeight))
    path.closeSubpath()

    return path
  }
}
