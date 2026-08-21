//
//  LocationFeedbackScreen.swift
//  Draft
//
//  Generator E — haptic ĐỊNH VỊ (iOS 17.5+).
//
//  ⚠️ NOTE: Not verified yet — chưa kiểm chứng trên máy thật.
//  Code compile được, nhưng cảm giác rung của impactOccurred(at:) và
//  UICanvasFeedbackGenerator chưa ai sờ tay xác nhận. Đừng dùng màn này
//  làm chuẩn đối chiếu cho tới khi đã thử trên iPhone.
//
//  Từ iOS 17.5, generator có thêm init(style:view:) và các method nhận
//  toạ độ: impactOccurred(at:), selectionChanged(at:), notificationOccurred(_:at:).
//  Hệ thống dùng toạ độ đó để căn chỉnh cú rung theo vị trí ngón tay.
//
//  Toạ độ phải nằm trong coordinate space của ĐÚNG view đã truyền vào init,
//  nên phần bắt chạm ở đây buộc phải xuống UIKit — SwiftUI không đưa cho ta
//  một UIView để làm mốc.
//

import SwiftUI
import UIKit

struct LocationFeedbackScreen: View {
  @State private var useLocation = true
  @State private var dots: [Dot] = []

  @State private var crossings = 0
  @State private var pathPoint: CGPoint?

  var body: some View {
    List {
      impactSection
      canvasSection
      caveatSection
    }
    .navigationTitle("Định vị")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - E1. impactOccurred(at:)

  private var impactSection: some View {
    Section {
      Toggle("Truyền toạ độ (at:)", isOn: $useLocation)

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.blue.opacity(0.10))

        ForEach(dots) { dot in
          Circle()
            .fill(Color.blue.opacity(0.55))
            .frame(width: 22, height: 22)
            .position(dot.point)
        }

        ImpactLocationPad(useLocation: useLocation) { point in
          dots.append(Dot(point: point))
          if dots.count > 12 { dots.removeFirst() }
        }
      }
      .frame(height: 220)
      .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

      Button("Xoá chấm") { dots.removeAll() }
        .disabled(dots.isEmpty)
    } header: {
      Text("E1. Chạm định vị")
    } footer: {
      Text("""
        Chạm khắp vùng xanh — sát mép trên, sát mép dưới, giữa. Bật/tắt toggle để so.

        Generator được tạo bằng init(style:view:) với chính view này làm mốc, nên toạ độ truyền vào \
        impactOccurred(at:) mới có ý nghĩa. Dùng init(style:) thường rồi gọi at: là vô nghĩa.
        """)
    }
  }

  // MARK: - E2. UICanvasFeedbackGenerator

  private var canvasSection: some View {
    Section {
      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.orange.opacity(0.10))

        GridLines(divisions: CanvasPad.divisions)
          .stroke(Color.orange.opacity(0.35), lineWidth: 1)

        if let pathPoint {
          Circle()
            .fill(Color.orange)
            .frame(width: 18, height: 18)
            .position(pathPoint)
        }

        CanvasPad(
          onCross: { crossings += 1 },
          onMove: { pathPoint = $0 },
          onEnd: { pathPoint = nil }
        )
      }
      .frame(height: 220)
      .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

      LabeledContent("Số lần qua vạch") {
        Text("\(crossings)")
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
    } header: {
      Text("E2. UICanvasFeedbackGenerator")
    } footer: {
      Text("""
        Kéo ngón chậm qua các ô. Mỗi lần vượt một vạch lưới là một alignmentOccurred(at:) — cảm giác \
        "khớp vào lưới" như khi kéo object trong Keynote. Nhấc ngón ra là pathCompleted(at:), một cú chốt khác hẳn.

        Class này (iOS 17.5+) sinh ra riêng cho canvas tự vẽ: nó chỉ có hai khái niệm là CĂN và XONG, \
        không có style hay intensity. Bạn mô tả sự kiện, hệ thống chọn cảm giác.
        """)
    }
  }

  // MARK: - Nói thật về giới hạn

  private var caveatSection: some View {
    Section {
      Label("NOTE: Not verified yet", systemImage: "exclamationmark.triangle.fill")
        .foregroundStyle(.orange)

      Label("iPhone chỉ có MỘT Taptic Engine", systemImage: "info.circle")
        .foregroundStyle(.secondary)
    } footer: {
      Text("""
        Đừng kỳ vọng rung ở góc trên trái nghe khác hẳn góc dưới phải — phần cứng không định vị được như vậy. \
        at: là thông tin bạn ĐƯA CHO hệ thống để nó tinh chỉnh, không phải lệnh chọn vị trí rung.

        Vậy vì sao vẫn nên truyền? Vì nó miễn phí, và vì đây là API hướng tới phần cứng tương lai \
        cùng các thiết bị nhiều actuator. Code viết đúng hôm nay thì mai không phải sửa.
        """)
    }
  }

  struct Dot: Identifiable {
    let id = UUID()
    let point: CGPoint
  }
}

// MARK: - Lưới vẽ bằng SwiftUI

private struct GridLines: Shape {
  let divisions: Int

  func path(in rect: CGRect) -> Path {
    var path = Path()
    for i in 1..<divisions {
      let x = rect.width / CGFloat(divisions) * CGFloat(i)
      path.move(to: CGPoint(x: x, y: 0))
      path.addLine(to: CGPoint(x: x, y: rect.height))

      let y = rect.height / CGFloat(divisions) * CGFloat(i)
      path.move(to: CGPoint(x: 0, y: y))
      path.addLine(to: CGPoint(x: rect.width, y: y))
    }
    return path
  }
}

// MARK: - Pad 1: impactOccurred(at:)

// Phải là UIViewRepresentable vì generator định vị cần một UIView thật
// làm hệ quy chiếu. Lớp này trong suốt, chỉ nằm trên để bắt chạm —
// toàn bộ phần nhìn vẫn do SwiftUI vẽ ở dưới.
private struct ImpactLocationPad: UIViewRepresentable {
  let useLocation: Bool
  let onTap: (CGPoint) -> Void

  func makeUIView(context: Context) -> PadView {
    let view = PadView()
    view.backgroundColor = .clear
    view.useLocation = useLocation
    view.onTap = onTap
    return view
  }

  func updateUIView(_ uiView: PadView, context: Context) {
    uiView.useLocation = useLocation
    uiView.onTap = onTap
  }

  final class PadView: UIView {
    var useLocation = true
    var onTap: ((CGPoint) -> Void)?

    // init(style:view:) — iOS 17.5+. `self` chính là hệ quy chiếu cho at:
    private lazy var generator = UIImpactFeedbackGenerator(style: .medium, view: self)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      generator.prepare()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      guard let point = touches.first?.location(in: self) else { return }

      if useLocation {
        generator.impactOccurred(at: point)
      } else {
        generator.impactOccurred()
      }
      onTap?(point)
    }
  }
}

// MARK: - Pad 2: UICanvasFeedbackGenerator

private struct CanvasPad: UIViewRepresentable {
  static let divisions = 4

  let onCross: () -> Void
  let onMove: (CGPoint) -> Void
  let onEnd: () -> Void

  func makeUIView(context: Context) -> PadView {
    let view = PadView()
    view.backgroundColor = .clear
    view.onCross = onCross
    view.onMove = onMove
    view.onEnd = onEnd
    return view
  }

  func updateUIView(_ uiView: PadView, context: Context) {
    uiView.onCross = onCross
    uiView.onMove = onMove
    uiView.onEnd = onEnd
  }

  final class PadView: UIView {
    var onCross: (() -> Void)?
    var onMove: ((CGPoint) -> Void)?
    var onEnd: (() -> Void)?

    private lazy var generator = UICanvasFeedbackGenerator(view: self)
    private var lastCell: (col: Int, row: Int)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      generator.prepare()
      guard let point = touches.first?.location(in: self) else { return }
      lastCell = cell(for: point)
      onMove?(point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesMoved(touches, with: event)
      guard let point = touches.first?.location(in: self) else { return }
      onMove?(point)

      let current = cell(for: point)
      // Chỉ bắn khi ĐỔI ô — nếu bắn theo mỗi touchesMoved thì thành rung liên tục,
      // mất hẳn cảm giác "khớp vào vạch".
      if let last = lastCell, last != current {
        generator.alignmentOccurred(at: point)
        onCross?()
      }
      lastCell = current
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      if let point = touches.first?.location(in: self) {
        generator.pathCompleted(at: point)
      }
      lastCell = nil
      onEnd?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      lastCell = nil
      onEnd?()
    }

    private func cell(for point: CGPoint) -> (col: Int, row: Int) {
      let w = bounds.width / CGFloat(CanvasPad.divisions)
      let h = bounds.height / CGFloat(CanvasPad.divisions)
      guard w > 0, h > 0 else { return (0, 0) }
      return (Int(point.x / w), Int(point.y / h))
    }
  }
}

#Preview {
  NavigationStack {
    LocationFeedbackScreen()
  }
}
