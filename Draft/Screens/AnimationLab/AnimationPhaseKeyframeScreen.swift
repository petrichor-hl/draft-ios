//
//  AnimationPhaseKeyframeScreen.swift
//  Draft
//
//  Bước 4 — Animation NHIỀU CHẶNG (iOS 17+).
//
//  withAnimation chỉ đi từ A tới B. Muốn A → B → C, hoặc muốn
//  scale và offset chạy theo hai nhịp khác nhau, cần hai công cụ:
//
//    PhaseAnimator    — danh sách TRẠNG THÁI rời rạc, đi lần lượt
//    KeyframeAnimator — timeline theo THỜI GIAN, mỗi thuộc tính một track
//

import SwiftUI

struct AnimationPhaseKeyframeScreen: View {
  @State private var heartTaps = 0
  @State private var jumps = 0

  var body: some View {
    List {
      phaseTriggerSection
      phaseLoopSection
      keyframeSection
      compareSection
    }
    .navigationTitle("Phase & Keyframe")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - ① PhaseAnimator có trigger: chạy một lượt rồi nghỉ

  private var phaseTriggerSection: some View {
    Section {
      Image(systemName: "heart.fill")
        .font(.system(size: 44))
        .foregroundStyle(.pink)
        .phaseAnimator(HeartPhase.allCases, trigger: heartTaps) { content, phase in
          content
            .scaleEffect(phase.scale)
            .opacity(phase.opacity)
        } animation: { phase in
          // Mỗi CHẶNG được cấp một animation riêng.
          switch phase {
          case .idle:   .smooth
          case .pop:    .spring(duration: 0.2, bounce: 0.6)
          case .settle: .easeOut(duration: 0.25)
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)

      Button("Thả tim") { heartTaps += 1 }
        .font(.headline)
    } header: {
      Text("① PhaseAnimator(_:trigger:)")
    } footer: {
      Text("Mỗi lần `trigger` đổi giá trị, SwiftUI đi hết một vòng phases rồi dừng lại ở phase đầu tiên. Bạn không tự quản lý state trung gian — chỉ mô tả \"trông như thế nào ở từng chặng\".")
    }
  }

  // MARK: - ② PhaseAnimator không trigger: lặp vô hạn

  private var phaseLoopSection: some View {
    Section {
      HStack(spacing: 10) {
        ForEach(0..<3) { index in
          Circle()
            .fill(.tint)
            .frame(width: 12, height: 12)
            .phaseAnimator([false, true]) { content, isUp in
              content.offset(y: isUp ? -10 : 0)
            } animation: { _ in
              // .delay lệch nhau tạo hiệu ứng sóng.
              .easeInOut(duration: 0.4).delay(Double(index) * 0.12)
            }
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
    } header: {
      Text("② Bỏ trigger đi thì nó lặp mãi")
    } footer: {
      Text("Không có trigger, PhaseAnimator quay vòng liên tục — dùng cho loading indicator, chấm \"đang gõ\", icon nhấp nháy. Ba chấm ở đây dùng chung một cặp phase [false, true], chỉ khác nhau ở .delay theo index.")
    }
  }

  // MARK: - ③ KeyframeAnimator: mỗi thuộc tính một timeline

  private var keyframeSection: some View {
    Section {
      RoundedRectangle(cornerRadius: 14)
        .fill(.tint)
        .frame(width: 60, height: 60)
        .keyframeAnimator(initialValue: JumpValues(), trigger: jumps) { content, value in
          content
            .scaleEffect(x: value.stretch, y: value.squash, anchor: .bottom)
            .rotationEffect(value.rotation)
            .offset(y: value.yOffset)
        } keyframes: { _ in
          // Track 1 — độ cao. Tổng 0.8s.
          KeyframeTrack(\.yOffset) {
            SpringKeyframe(-90, duration: 0.35, spring: .bouncy)
            SpringKeyframe(0, duration: 0.45, spring: .bouncy)
          }

          // Track 2 — bẹp/giãn. Tổng 0.8s nhưng chia nhỏ hơn.
          KeyframeTrack(\.squash) {
            LinearKeyframe(0.7, duration: 0.12)   // nhún lấy đà
            CubicKeyframe(1.25, duration: 0.23)   // bật lên, kéo dài người
            CubicKeyframe(1.0, duration: 0.2)
            CubicKeyframe(0.75, duration: 0.1)    // chạm đất, bẹp xuống
            SpringKeyframe(1.0, duration: 0.15, spring: .bouncy)
          }

          KeyframeTrack(\.stretch) {
            LinearKeyframe(1.25, duration: 0.12)
            CubicKeyframe(0.85, duration: 0.23)
            CubicKeyframe(1.0, duration: 0.2)
            CubicKeyframe(1.2, duration: 0.1)
            SpringKeyframe(1.0, duration: 0.15, spring: .bouncy)
          }

          // Track 3 — nghiêng nhẹ khi đang bay.
          KeyframeTrack(\.rotation) {
            CubicKeyframe(.degrees(-10), duration: 0.35)
            CubicKeyframe(.degrees(0), duration: 0.45)
          }
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .bottom)
        .padding(.vertical, 8)

      Button("Nhảy") { jumps += 1 }
        .font(.headline)
    } header: {
      Text("③ KeyframeAnimator(initialValue:trigger:)")
    } footer: {
      Text("""
      `JumpValues` là một struct thường, mỗi property là một track riêng biệt và CHẠY ĐỘC LẬP: yOffset chỉ có 2 mốc, còn squash có 5 mốc trong cùng khoảng thời gian. Đó là điều PhaseAnimator không làm được.

      Bốn loại mốc: LinearKeyframe (đều), CubicKeyframe (bézier, nối mượt với mốc kề bên), SpringKeyframe (vật lý), MoveKeyframe (nhảy tức thì, không nội suy).

      `duration` của mỗi keyframe là thời gian ĐI TỚI mốc đó, tính từ mốc trước — không phải mốc thời gian tuyệt đối.
      """)
    }
  }

  // MARK: - ④ Chọn cái nào

  private var compareSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 10) {
        row("withAnimation", "Một chặng A → B. 90% nhu cầu thật.")
        row("PhaseAnimator", "Nhiều chặng, mô tả theo TRẠNG THÁI. Các thuộc tính đi cùng nhau, sang chặng mới khi chặng trước xong.")
        row("KeyframeAnimator", "Nhiều chặng, mô tả theo THỜI GIAN. Mỗi thuộc tính một timeline riêng. Tốn công hơn — chỉ dùng khi thật sự cần dàn dựng.")
      }
      .padding(.vertical, 4)
    } header: {
      Text("④ Dùng cái nào")
    } footer: {
      Text("Cả hai đều là animation \"chạy tự động\", không nhận input liên tục. Nếu chuyển động phải bám theo ngón tay người dùng thì vẫn là DragGesture + state, như bài Swipe to Confirm.")
    }
  }

  private func row(_ title: String, _ detail: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.subheadline.weight(.semibold))
      Text(detail).font(.caption).foregroundStyle(.secondary)
    }
  }
}

// MARK: - Các chặng của trái tim

private enum HeartPhase: CaseIterable {
  case idle, pop, settle

  var scale: Double {
    switch self {
    case .idle:   1.0
    case .pop:    1.5
    case .settle: 0.92
    }
  }

  var opacity: Double {
    switch self {
    case .idle:   1.0
    case .pop:    0.85
    case .settle: 1.0
    }
  }
}

// MARK: - Các track của cú nhảy

// Mỗi property ở đây trở thành một KeyframeTrack độc lập.
private struct JumpValues {
  var yOffset: Double = 0
  var squash: Double = 1     // scale theo trục Y
  var stretch: Double = 1    // scale theo trục X
  var rotation: Angle = .zero
}

#Preview {
  NavigationStack {
    AnimationPhaseKeyframeScreen()
  }
}
