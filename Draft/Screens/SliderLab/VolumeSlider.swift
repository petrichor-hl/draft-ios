//
//  VolumeSlider.swift
//  Draft
//
//  Thanh âm lượng 0–100%: icon loa đổi theo giá trị, nhãn % nổi trên thumb
//  trong lúc kéo.
//
//  So với `MacroSplitBar` thì state dễ hơn hẳn — một thumb, một số, không còn
//  hệ biên nên cũng không cần `resolveThumb`. Cái khó dời sang ba chỗ khác:
//
//  1. TOẠ ĐỘ KHÔNG PHẢI LÀ BỀ NGANG. Thumb có đường kính 28, và ở 0% nó phải
//     nằm GỌN trong thanh chứ không thò ra ngoài mép trái. Vậy quãng đường
//     thumb đi được là `width − thumbSize`, không phải `width`:
//
//         percent 0   → mép trái thumb ở 0,      tâm thumb ở 14
//         percent 100 → mép trái thumb ở W−28,   tâm thumb ở W−14
//
//     Kéo theo đó, đổi từ toạ độ chạm về phần trăm phải TRỪ nửa thumb trước
//     khi chia. Quên phép trừ này thì chạm sát mép phải không bao giờ ra 100%,
//     và thumb luôn lệch khỏi ngón tay một đoạn 14pt.
//
//  2. CHẠM ĐÂU NHẢY ĐÓ, RỒI KÉO BÁM. Hai kỹ thuật ghép vào một gesture:
//     `startLocation` cho cú nhảy lúc chạm, `translation` cho phần kéo tiếp
//     sau đó. Mốc `anchor` vì thế lấy từ VỊ TRÍ CHẠM chứ không phải từ giá trị
//     đang có — khác `MacroSplitBar`, nơi chạm không được phép đổi gì.
//
//  3. NHÃN PHẢI BIẾT DỪNG Ở MÉP. Nhãn bám tâm thumb, nhưng ở 0% và 100% thì
//     tâm thumb cách mép chỉ 14pt trong khi nhãn rộng 52 — không kẹp thì nó
//     thò ra ngoài. Kẹp offset trong `[0, width − labelWidth]`.
//

import SwiftUI

struct VolumeSlider: View {
  @Binding var percent: Int
  var icon: IconMode = .threshold

  enum IconMode {
    /// Một symbol duy nhất, sóng tự đầy dần theo tỉ lệ — SF Symbols 4 / iOS 16.
    case variableValue
    /// Tự chia bốn mốc rồi đổi hẳn symbol.
    case threshold
  }

  /// Giá trị tại điểm CHẠM, sau khi cú nhảy đã xong. `nil` nghĩa là không có
  /// ngón tay nào trên thanh — cũng là cờ bật tắt nhãn %.
  @State private var anchor: Int?

  private var isDragging: Bool { anchor != nil }

  private static let thumbSize: CGFloat = 28
  private static let trackHeight: CGFloat = 10
  private static let labelWidth: CGFloat = 52
  private static let labelHeight: CGFloat = 24
  private static let labelGap: CGFloat = 6
  private static let iconWidth: CGFloat = 32

  var body: some View {
    HStack(spacing: 12) {
      // Khung CỐ ĐỊNH, không để icon tự co: speaker.wave.1 hẹp hơn
      // speaker.wave.3 vài pt, thả tự do thì mỗi lần đổi symbol cả thanh bên
      // phải lại nhích một cái. Hai hàng cạnh nhau cũng lệch nhau luôn.
      iconView
        .font(.title3)
        .frame(width: Self.iconWidth, alignment: .leading)

      GeometryReader { geo in
        let width = geo.size.width
        let travel = travel(in: width)
        // Mép TRÁI của thumb. Tâm nằm ở `thumbX + thumbSize / 2`.
        let thumbX = travel * CGFloat(percent) / 100

        VStack(alignment: .leading, spacing: Self.labelGap) {
          label(thumbX: thumbX, in: width)

          ZStack(alignment: .leading) {
            Capsule()
              .fill(Color.gray.s200)
              .frame(height: Self.trackHeight)

            // Phần đã tô dừng ở TÂM thumb, không phải mép trái nó — nếu không
            // thì ở 100% vẫn hở ra một khoảng 14pt chưa tô.
            Capsule()
              .fill(Color.accentColor)
              .frame(width: thumbX + Self.thumbSize / 2, height: Self.trackHeight)

            thumb.offset(x: thumbX)
          }
          .frame(height: Self.thumbSize)
        }
        // Cả dải — kể cả khoảng trống chỗ nhãn — đều nhận touch.
        .contentShape(.rect)
        .gesture(drag(in: width))
      }
      .frame(height: Self.labelHeight + Self.labelGap + Self.thumbSize)
    }
  }

  // MARK: - Views

  @ViewBuilder
  private var iconView: some View {
    switch icon {
    case .variableValue:
      Image(systemName: "speaker.wave.3.fill", variableValue: Double(percent) / 100)
    case .threshold:
      Image(systemName: thresholdSymbol)
        // Không có modifier này thì symbol đổi kiểu cắt hình; có nó thì hai
        // symbol hoà vào nhau. Cần một animation đi kèm mới chạy, mà giá trị
        // do ngón tay đẩy thì không mang animation nào theo.
        .contentTransition(.symbolEffect(.replace))
        .animation(.snappy(duration: 0.2), value: thresholdSymbol)
    }
  }

  /// Bốn mốc tự chia. `speaker.slash` ở 0 là chỗ variable value không tự làm
  /// được: ở tỉ lệ 0 nó chỉ tắt hết sóng chứ không gạch chéo.
  private var thresholdSymbol: String {
    switch percent {
    case ...0: "speaker.slash.fill"
    case 1...33: "speaker.wave.1.fill"
    case 34...66: "speaker.wave.2.fill"
    default: "speaker.wave.3.fill"
    }
  }

  private var thumb: some View {
    Circle()
      .fill(Color(.systemBackground))
      .frame(width: Self.thumbSize, height: Self.thumbSize)
      .compositingGroup()
      .shadow(color: Color.primary.opacity(0.18), radius: 3, y: 1)
  }

  private func label(thumbX: CGFloat, in width: CGFloat) -> some View {
    Text(verbatim: "\(percent)%")
      .font(.caption.bold())
      .monospacedDigit()
      .foregroundStyle(Color(.systemBackground))
      .frame(width: Self.labelWidth, height: Self.labelHeight)
      .background(Color.primary, in: .capsule)
      .offset(x: labelX(thumbX: thumbX, in: width))
      .opacity(isDragging ? 1 : 0)
      .scaleEffect(isDragging ? 1 : 0.7, anchor: .bottom)
      .animation(.snappy(duration: 0.2), value: isDragging)
      // Chiều cao giữ nguyên dù nhãn ẩn: cho nhãn chiếm chỗ hẳn thì lúc hiện
      // ra thanh không bị đẩy xuống.
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - Kéo

  private func drag(in width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        guard width > 0 else { return }
        let travel = travel(in: width)

        // Cú chạm: nhảy thẳng tới chỗ ngón tay, và chính chỗ đó thành mốc.
        if anchor == nil {
          anchor = percent(atX: gesture.startLocation.x, travel: travel)
        }

        guard let anchor else { return }
        let delta = Int((gesture.translation.width / travel * 100).rounded())
        percent = clamped(anchor + delta)
      }
      .onEnded { _ in anchor = nil }
  }

  // MARK: - Toạ độ

  private func travel(in width: CGFloat) -> CGFloat {
    max(width - Self.thumbSize, 1)
  }

  private func percent(atX x: CGFloat, travel: CGFloat) -> Int {
    clamped(Int(((x - Self.thumbSize / 2) / travel * 100).rounded()))
  }

  private func labelX(thumbX: CGFloat, in width: CGFloat) -> CGFloat {
    let centered = thumbX + Self.thumbSize / 2 - Self.labelWidth / 2
    return min(max(centered, 0), max(width - Self.labelWidth, 0))
  }

  private func clamped(_ value: Int) -> Int {
    min(max(value, 0), 100)
  }
}

#Preview {
  @Previewable @State var percent = 60

  VStack(spacing: 24) {
    VolumeSlider(percent: $percent, icon: .variableValue)
    VolumeSlider(percent: $percent, icon: .threshold)
  }
  .padding()
}
