//
//  MacroSplitBar.swift
//  Draft
//
//  Tỉ lệ macro vẽ thành MỘT thanh, hai thumb kéo hai cái biên giữa ba đoạn.
//
//  Clone từ dietfit-ios — Packages/Features/Sources/Profile/Components/
//  ProfileFields/MacroSplitBar.swift. Phần logic giữ nguyên từng dòng; chỗ đổi
//  chỉ là token DesignSystem (Spacing, Radius, Color.*, .shadow(.small)) thay
//  bằng số và màu viết thẳng, vì Draft không có package đó.
//
//  ĐIỂM CỐT LÕI — state là BA số nhưng tay người chỉ kéo được HAI thứ:
//
//      lower = carb              biên carb | protein
//      upper = carb + protein    biên protein | fat
//
//  Mọi phép kẹp làm trên hệ biên, xong mới đổi ngược về ba số (`move(_:to:)`).
//  Nhờ vậy mỗi thumb chỉ đụng đúng hai macro kề nó, macro còn lại đứng yên, và
//  tổng luôn giữ nguyên: kéo lower từ 45 xuống 30 thì carb 30, protein 50, fat
//  vẫn 20.
//

import SwiftUI

struct MacroSplitBar: View {
  @Binding var carb: Int
  @Binding var protein: Int
  @Binding var fat: Int

  private enum Thumb {
    case lower
    case upper
  }

  @State private var activeThumb: Thumb?
  /// Giá trị của biên đang kéo LÚC BẮT ĐẦU kéo. Mỗi `onChanged` mang
  /// `translation` tính từ điểm bắt đầu, nên không có mốc này thì các delta
  /// cộng dồn lên nhau và thumb chạy vọt.
  @State private var anchor = 0

  private static let barHeight: CGFloat = 12
  private static let thumbWidth: CGFloat = 20
  private static let thumbHeight: CGFloat = 28
  private static let thumbBorder: CGFloat = 3

  private var lower: Int { carb }
  private var upper: Int { carb + protein }

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width
      let widths = segmentWidths(in: width)

      ZStack(alignment: .leading) {
        HStack(spacing: 0) {
          MacroType.carb.accentColor.frame(width: widths[0])
          MacroType.protein.accentColor.frame(width: widths[1])
          MacroType.fat.accentColor.frame(width: widths[2])
        }
        .frame(height: Self.barHeight)
        .clipShape(.capsule)

        thumb.offset(x: widths[0] - Self.thumbWidth / 2)
        thumb.offset(x: widths[0] + widths[1] - Self.thumbWidth / 2)
      }
      .frame(height: geo.size.height)
      // MỘT gesture cho cả hai thumb, đặt trên toàn dải: hai gesture rời không
      // phân xử được touch thuộc thumb nào khi hai thumb chồng lên nhau.
      // `.contentShape(.rect)` vì ZStack có khoảng trống không nhận touch.
      .contentShape(.rect)
      .gesture(drag(in: width))
    }
    .frame(height: Self.thumbHeight)
  }

  private var thumb: some View {
    Capsule()
      .fill(Color.primary)
      .frame(width: Self.thumbWidth, height: Self.thumbHeight)
      .overlay {
        Capsule()
          .strokeBorder(Color(.systemBackground), lineWidth: Self.thumbBorder)
      }
      // Bản gốc dùng `.shadow(.small)` của DesignSystem: compositingGroup rồi
      // đổ bóng #111111 ở alpha 5%, bán kính 2, lệch xuống 2.
      .compositingGroup()
      .shadow(color: Color.primary.opacity(0.05), radius: 2, y: 2)
  }

  // MARK: - Kéo

  private func drag(in width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        guard width > 0 else { return }

        if activeThumb == nil {
          guard let picked = resolveThumb(
            startX: value.startLocation.x,
            in: width,
            translation: value.translation.width
          ) else { return }
          activeThumb = picked
          anchor = boundary(of: picked)
        }

        guard let thumb = activeThumb else { return }
        let delta = Int((value.translation.width / width * 100).rounded())
        move(thumb, to: anchor + delta)
      }
      .onEnded { _ in activeThumb = nil }
  }

  /// Thumb gần chỗ chạm nhất, TRỪ khi hai thumb đang ở cùng một phần trăm —
  /// lúc đó khoảng cách không phân biệt được, mà chọn nhầm cái đang bị chặn thì
  /// cặp thumb kẹt luôn ở mép, không mở lại đoạn giữa được. Ca đó xét HƯỚNG
  /// kéo, nên kéo ra khỏi đống bao giờ cũng banh đoạn giữa ra.
  private func resolveThumb(startX: CGFloat, in width: CGFloat, translation: CGFloat) -> Thumb? {
    guard lower != upper else {
      guard translation != 0 else { return nil }
      return translation > 0 ? .upper : .lower
    }

    let percent = Double(startX / width * 100)
    return abs(percent - Double(lower)) <= abs(percent - Double(upper)) ? .lower : .upper
  }

  private func boundary(of thumb: Thumb) -> Int {
    switch thumb {
    case .lower: lower
    case .upper: upper
    }
  }

  /// Cả hai nhánh ĐỌC giới hạn trước rồi mới ghi, vì `lower` và `upper` là
  /// computed từ chính mấy biến sắp bị gán — ghi `carb` trước rồi đọc `upper`
  /// là đọc phải con số đã đổi.
  private func move(_ thumb: Thumb, to percent: Int) {
    switch thumb {
    case .lower:
      let ceiling = upper
      let value = min(max(percent, 0), ceiling)
      carb = value
      protein = ceiling - value
    case .upper:
      let floor = lower
      let value = min(max(percent, floor), 100)
      protein = value - floor
      fat = 100 - value
    }
  }

  /// Chia bề ngang theo phần của TỔNG THẬT chứ không phải của 100, để hồ sơ
  /// chưa có tỉ lệ (0/0/0) vẽ ra thanh rỗng thay vì thanh đầy. Còn lúc kéo thì
  /// làm việc theo phần trăm của 100 và tự đưa tổng về đúng.
  private func segmentWidths(in width: CGFloat) -> [CGFloat] {
    let total = carb + protein + fat
    guard total > 0 else { return [0, 0, 0] }
    return [carb, protein, fat].map { width * CGFloat($0) / CGFloat(total) }
  }
}

#Preview {
  @Previewable @State var carb = 45
  @Previewable @State var protein = 35
  @Previewable @State var fat = 20

  VStack(spacing: 24) {
    MacroSplitBar(carb: $carb, protein: $protein, fat: $fat)
    Text(verbatim: "\(carb) / \(protein) / \(fat)")
      .monospacedDigit()
  }
  .padding()
}
