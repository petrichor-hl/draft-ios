//
//  AnimationCurvesScreen.swift
//  Draft
//
//  Bước 2 — Cùng một quãng đường, khác đường cong.
//
//  Mọi track dưới đây chạy CÙNG LÚC, cùng đi từ trái sang phải.
//  Khác biệt duy nhất là Animation truyền vào .animation(_:value:).
//

import SwiftUI

struct AnimationCurvesScreen: View {
  // Một state duy nhất kéo tất cả các chấm chạy.
  @State private var go = false

  // Duration dùng chung cho nhóm timing curve.
  @State private var duration: Double = 1.0

  // Tham số cho spring tự chỉnh ở section cuối.
  @State private var response: Double = 0.55
  @State private var damping: Double = 0.825

  var body: some View {
    List {
      timingCurveSection
      springPresetSection
      springDurationSection
      modifierSection
      springTunerSection
    }
    .navigationTitle("Curves")
    .navigationBarTitleDisplayMode(.inline)

    // Thanh điều khiển dính đáy: không phải cuộn ngược lên đầu để bấm.
    .safeAreaInset(edge: .bottom) {
      controlBar
    }
  }

  // MARK: - Thanh điều khiển dính đáy

  private var controlBar: some View {
    VStack(spacing: 8) {
      Button {
        go.toggle()
      } label: {
        Label(go ? "Chạy về" : "Chạy tới",
              systemImage: go ? "arrow.left" : "arrow.right")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)

      HStack(spacing: 10) {
        Text("duration")
          .font(.caption)
          .foregroundStyle(.secondary)
        Slider(value: $duration, in: 0.2...3)
        Text(duration, format: .number.precision(.fractionLength(2)))
          .font(.caption)
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 10)
    .background(.bar)
  }

  // MARK: - ① Timing curve: chia thời gian theo tỉ lệ

  private var timingCurveSection: some View {
    Section {
      CurveTrack("linear", .linear(duration: duration), go: go)
      CurveTrack("easeIn", .easeIn(duration: duration), go: go)
      CurveTrack("easeOut", .easeOut(duration: duration), go: go)
      CurveTrack("easeInOut", .easeInOut(duration: duration), go: go)
    } header: {
      Text("① Timing curve")
    } footer: {
      Text("""
      Slider duration ở thanh dưới chỉ nối vào nhóm này; spring có duration riêng (section ②b).

      linear — tốc độ không đổi suốt quãng đường. Không vật thật nào chuyển động kiểu này, nên mắt đọc ra ngay là "máy móc".

      easeIn — khởi động chậm rồi nhanh dần, kết thúc ở lúc nhanh nhất. Hợp cho thứ đang RỜI ĐI khỏi màn hình: nó lao đi và biến mất.

      easeOut — bắt đầu nhanh rồi hãm dần, dừng êm. Hợp cho thứ đang XUẤT HIỆN: tới ngay trước mắt rồi từ từ đậu lại.

      easeInOut — chậm ở CẢ HAI ĐẦU, nhanh ở giữa. Dùng khi điểm đi và điểm đến đều nằm trên màn hình.

      Vậy khi nào easeInOut, khi nào spring? Spring có đà nên nó VỌT QUA ĐÍCH rồi quay lại. Điều đó chỉ có nghĩa với thứ chuyển động trong không gian (vị trí, kích thước). Với opacity hay màu sắc thì nảy là vô nghĩa — độ mờ 1.05 không tồn tại, màu vọt qua rồi lùi lại trông như lỗi render. Nên: fade và đổi màu → easeInOut; di chuyển và phóng to → spring.
      """)
    }
  }

  // MARK: - ② Spring: mô phỏng lò xo

  private var springPresetSection: some View {
    Section {
      CurveTrack("smooth", .smooth, go: go)
      CurveTrack("snappy", .snappy, go: go)
      CurveTrack("bouncy", .bouncy, go: go)
      CurveTrack("spring (mặc định)", .spring, go: go)
    } header: {
      Text("② Spring preset (iOS 17+)")
    } footer: {
      Text("""
      Ba preset Apple khuyến nghị dùng làm mặc định: 
      - smooth (không nảy), 
      - snappy (nảy nhẹ, dứt khoát — hợp tap/toggle), 
      - bouncy (nảy rõ, vui).

      Ưu thế thật sự của spring nằm ở chỗ nó GIỮ VẬN TỐC: nếu bạn đổi đích giữa chừng (kéo, thả, đổi ý), spring nối tiếp mượt còn timing curve thì khựng lại rồi chạy đoạn mới.
      """)
    }
  }

  // MARK: - ②b Spring CÓ duration

  private var springDurationSection: some View {
    Section {
      // Ba dòng đầu chạy giống hệt nhau nếu preset đúng là
      // spring(duration: 0.5, bounce: 0.15).
      CurveTrack("snappy", .snappy, go: go)
      CurveTrack("snappy(duration: 0.5)", .snappy(duration: 0.5), go: go)
      CurveTrack("spring(duration: .5, bounce: .15)", .spring(duration: 0.5, bounce: 0.15), go: go)

      // Kéo duration ra 2 giây: cùng độ nảy, chỉ chậm hơn.
      CurveTrack("snappy(duration: 2)", .snappy(duration: 2), go: go)
      CurveTrack("bouncy(extraBounce: 0.2)", .bouncy(duration: 0.5, extraBounce: 0.2), go: go)
    } header: {
      Text("②b Spring cũng có duration")
    } footer: {
      Text("""
      Ba dòng đầu chồng khít lên nhau: .snappy CHÍNH LÀ spring(duration: 0.5, bounce: 0.15). Tương tự .smooth = bounce 0, .bouncy = bounce 0.3. Cả ba đều nhận (duration:) và (duration:extraBounce:).

      Nhưng duration của spring KHÔNG phải "chạy xong sau ngần ấy giây" như timing curve. Apple gọi nó là perceptual duration — thời gian cảm nhận được là đã tới nơi. Với bounce > 0, phần nảy dư vẫn còn lắc thêm sau mốc đó (chính vì vậy withAnimation(completion:) mới cần phân biệt .logicallyComplete với .removed).

      Cách nhớ: timing curve có duration + đường cong. Spring có duration + độ nảy. Cùng một núm "bao lâu", khác cái núm thứ hai.
      """)
    }
  }

  // MARK: - ③ Bộ chỉnh gắn lên mọi Animation

  private var modifierSection: some View {
    Section {
      CurveTrack(".delay(0.5)", .easeInOut(duration: duration).delay(0.5), go: go)
      CurveTrack(".speed(2)", .easeInOut(duration: duration).speed(2), go: go)
      CurveTrack(".repeatCount(3)", .easeInOut(duration: duration).repeatCount(3, autoreverses: true), go: go)
      CurveTrack(".repeatForever()", .linear(duration: duration).repeatForever(autoreverses: true), go: go)
    } header: {
      Text("③ Modifier")
    } footer: {
      Text("Chúng trả về Animation mới nên nối chuỗi được: .easeInOut(duration: 0.3).delay(0.1).speed(2). Lưu ý .speed(2) tương đương chia đôi duration, và autoreverses: true nghĩa là mỗi lượt lặp gồm đi + về.")
    }
  }

  // MARK: - ④ Tự chỉnh spring

  private var springTunerSection: some View {
    Section {
      CurveTrack("spring(response:dampingFraction:)",
                 .spring(response: response, dampingFraction: damping),
                 go: go)

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text("response")
          Spacer()
          Text(response, format: .number.precision(.fractionLength(2)))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        Slider(value: $response, in: 0.1...2)
      }

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text("dampingFraction")
          Spacer()
          Text(damping, format: .number.precision(.fractionLength(2)))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        Slider(value: $damping, in: 0.1...1)
      }
    } header: {
      Text("④ Hai núm vặn của spring")
    } footer: {
      Text("""
      response = độ "cứng" của lò xo, hiểu nôm na là bao lâu để đi hết một dao động. Nhỏ → nhanh và gắt, lớn → chậm và lười.

      dampingFraction = ma sát. 1.0 là tới đích rồi dừng, không nảy (critically damped). Càng nhỏ càng nảy qua nảy lại; thử 0.2 để thấy rõ.
      """)
    }
  }
}

// MARK: - Một đường đua

// Chấm tròn chạy từ mép trái sang mép phải của hàng.
// Toàn bộ khác biệt giữa các hàng nằm ở tham số `animation`.
private struct CurveTrack: View {
  let name: String
  let animation: Animation
  let go: Bool

  private let dot: CGFloat = 18

  init(_ name: String, _ animation: Animation, go: Bool) {
    self.name = name
    self.animation = animation
    self.go = go
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(name)
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)

      // GeometryReader để biết hàng rộng bao nhiêu → tính đích đến.
      GeometryReader { geo in
        Circle()
          .fill(.tint)
          .frame(width: dot, height: dot)
          .offset(x: go ? geo.size.width - dot : 0)
          .animation(animation, value: go)
      }
      .frame(height: dot)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    AnimationCurvesScreen()
  }
}
