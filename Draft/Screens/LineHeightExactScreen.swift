//
//  LineHeightExactScreen.swift
//  Draft
//

import SwiftUI

/// Playground cho `.lineHeight(.exact(points:))` — API mới của iOS 26.
/// Kéo slider để đổi line height (đơn vị point) và font size, lưới đỏ vẽ
/// mỗi `lineHeight` point để kiểm chứng các dòng có rơi đúng ô hay không.
struct LineHeightExactScreen: View {
  @State private var lineHeight: CGFloat = 24
  @State private var fontSize: CGFloat = 17
  @State private var showsBaselineGrid = true
  
  private let sample = """
    SwiftUI trên iOS 26 cho phép set line height chính xác theo point, \
    thay vì chỉ cộng thêm khoảng cách như `.lineSpacing`. Đoạn text này \
    đủ dài để wrap thành nhiều dòng nên bạn thấy được khác biệt.
    """
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        exactSample
        
        Divider()
        
        controls
      }
      .padding()
    }
    .navigationTitle(".lineHeight(.exact) - iOS 26")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  /// `.lineHeight(_:)` chỉ có từ iOS 26; deployment target của project là
  /// 18.6 nên phải gate lại, máy cũ hơn sẽ thấy placeholder.
  private var exactSample: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(".lineHeight(.exact(points: \(Int(lineHeight))))")
        .font(.caption.monospaced())
        .foregroundStyle(.secondary)

      Group {
        if #available(iOS 26.0, *) {
          Text(sample)
            .font(.system(size: fontSize))
            .lineHeight(.exact(points: lineHeight))
        } else {
          Text("`.lineHeight` cần iOS 26.")
            .font(.system(size: fontSize))
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(8)
      .background {
        if showsBaselineGrid {
          BaselineGrid(step: lineHeight)
        }
      }
      .background(Color.yellow.opacity(0.12))
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
  
  private var controls: some View {
    VStack(alignment: .leading, spacing: 16) {
      labeledSlider(
        "Line height",
        value: $lineHeight,
        range: 10...60,
        display: "\(Int(lineHeight)) pt"
      )
      
      labeledSlider(
        "Font size",
        value: $fontSize,
        range: 10...40,
        display: "\(Int(fontSize)) pt"
      )
      
      Toggle("Hiện lưới line height", isOn: $showsBaselineGrid)
        .font(.subheadline.weight(.medium))
      
      Button("Reset") {
        lineHeight = 24
        fontSize = 17
      }
      .buttonStyle(.bordered)
      .frame(maxWidth: .infinity)
    }
  }
  
  private func labeledSlider(
    _ title: String,
    value: Binding<CGFloat>,
    range: ClosedRange<CGFloat>,
    display: String
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(title)
          .font(.subheadline.weight(.medium))
        Spacer()
        Text(display)
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.secondary)
      }
      Slider(value: value, in: range, step: 1)
    }
  }
}

/// Vẽ các đường ngang cách nhau đúng `step` point để mắt thường kiểm chứng
/// được là mỗi dòng text có rơi đúng vào một ô lưới hay không.
private struct BaselineGrid: View {
  let step: CGFloat
  
  var body: some View {
    Canvas { context, size in
      guard step > 1 else { return }
      var y: CGFloat = 0
      while y <= size.height {
        let line = Path { path in
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(line, with: .color(.red.opacity(0.25)), lineWidth: 0.5)
        y += step
      }
    }
  }
}

#Preview {
  NavigationStack {
    LineHeightExactScreen()
  }
}
