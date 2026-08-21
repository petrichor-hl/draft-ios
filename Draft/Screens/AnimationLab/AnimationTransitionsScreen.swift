//
//  AnimationTransitionsScreen.swift
//  Draft
//
//  Bước 3 — Transition: view XUẤT HIỆN / BIẾN MẤT.
//
//  Animation nội suy giá trị của view ĐANG TỒN TẠI.
//  Transition lo hai khoảnh khắc animation không với tới được:
//  lúc view được chèn vào cây và lúc nó bị gỡ ra.
//

import SwiftUI

struct AnimationTransitionsScreen: View {
  @State private var kind: TransitionKind = .opacity
  @State private var isShown = false

  // Cho section contentTransition ở cuối.
  @State private var score = 0
  @State private var isPlaying = false

  var body: some View {
    List {
      triggerSection
      trapSection
      contentTransitionSection
    }
    .navigationTitle("Transitions")
    .navigationBarTitleDisplayMode(.inline)

    // Sân khấu đặt NGOÀI List. Để trong một row của List thì
    // transition lúc CHÈN VÀO bị nuốt mất (đo bằng video: banner
    // hiện thẳng ở vị trí cuối, không có frame trung gian nào),
    // trong khi lúc GỠ RA vẫn chạy bình thường.
    .safeAreaInset(edge: .top) {
      stageArea
    }
  }

  // MARK: - Sân khấu

  private var stageArea: some View {
    VStack(spacing: 8) {
      Picker("Transition", selection: $kind) {
        ForEach(TransitionKind.allCases) { kind in
          Text(kind.rawValue).tag(kind)
        }
      }
      .pickerStyle(.menu)

      // Khung cố định để layout không co giãn theo banner.
      ZStack {
        if isShown {
          banner
            .transition(kind.transition)   // ① gắn LÊN VIEW được chèn/gỡ
        }
      }
      .frame(maxWidth: .infinity, minHeight: 90)
      .clipped()                           // ② cắt phần trượt ra ngoài
    }
    .padding(.horizontal)
    .padding(.bottom, 8)
    .background(.bar)
  }

  private var banner: some View {
    HStack(spacing: 12) {
      Image(systemName: "checkmark.circle.fill")
        .font(.title2)
      VStack(alignment: .leading, spacing: 2) {
        Text("Đã lưu").font(.headline)
        Text("Bản nháp của bạn an toàn").font(.caption)
      }
      Spacer()
    }
    .padding()
    .background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    .foregroundStyle(.tint)
  }

  // MARK: - ① Ai cho phép transition chạy

  private var triggerSection: some View {
    Section {
      Button(isShown ? "Ẩn (có animation)" : "Hiện (có animation)") {
        withAnimation(.snappy) { isShown.toggle() }
      }
      .font(.headline)

      Button(isShown ? "Ẩn (không animation)" : "Hiện (không animation)") {
        isShown.toggle()
      }
      .foregroundStyle(.secondary)
    } header: {
      Text("① Transition cần một animation đang hiệu lực")
    } footer: {
      Text("Nút thứ hai làm banner nhấp nháy xuất hiện/biến mất tức thì, dù .transition vẫn nằm nguyên đó. Transition chỉ MÔ TẢ hình thù của việc vào/ra; ai cấp thời gian cho nó là withAnimation (hoặc .animation(_:value:) đặt ngoài container).")
    }
  }

  // MARK: - ② Cái bẫy identity

  private var trapSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 8) {
        Text("insertion ≠ removal")
          .font(.subheadline.weight(.semibold))
        Text("""
        .asymmetric(insertion:removal:) cho phép vào một kiểu, ra một kiểu. Rất hay dùng: trượt vào từ dưới, mờ dần khi ra — vì người dùng không cần thấy đường đi của thứ sắp biến mất.
        """)
        .font(.caption)
        .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)

      VStack(alignment: .leading, spacing: 8) {
        Text("Không có `if` thì không có transition")
          .font(.subheadline.weight(.semibold))
        Text("""
        SwiftUI chỉ chạy transition khi IDENTITY của view thay đổi — view mới xuất hiện hoặc view cũ mất đi. Nếu bạn chỉ đổi nội dung (Text("A") → Text("B")) thì view vẫn là chính nó, không có gì để chèn hay gỡ. Muốn ép có transition, gắn .id(value) để mỗi giá trị là một view khác nhau.
        """)
        .font(.caption)
        .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)
      VStack(alignment: .leading, spacing: 8) {
        Text("Đừng đặt trong row của List")
          .font(.subheadline.weight(.semibold))
        Text("""
        Sân khấu ở màn này lúc đầu nằm trong một row của List và transition lúc CHÈN VÀO bị nuốt mất, dù lúc GỠ RA vẫn chạy. Đo bằng video, mép phải của banner khi hiện ra: trong List là -1 → 716 (một bước), ngoài List là -1 → 301 → 414 → 529 → 609 → 646 → 648. Nay nó nằm ngoài List, gắn bằng .safeAreaInset(edge: .top).
        """)
        .font(.caption)
        .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)
    } header: {
      Text("② Ba điều dễ vấp")
    }
  }

  // MARK: - ③ contentTransition: đổi nội dung, giữ nguyên view

  private var contentTransitionSection: some View {
    Section {
      LabeledContent("Điểm") {
        Text("\(score)")
          .font(.title2.monospacedDigit())
          .contentTransition(.numericText())
      }

      Button("+ 7") {
        withAnimation(.snappy) { score += 7 }
      }

      LabeledContent("Symbol") {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
          .font(.title2)
          .contentTransition(.symbolEffect(.replace))
      }

      Button(isPlaying ? "Pause → Play" : "Play → Pause") {
        withAnimation { isPlaying.toggle() }
      }
    } header: {
      Text("③ contentTransition")
    } footer: {
      Text("Nhớ mục ② của bài Basics: Int và String không animate được. .numericText() là cách SwiftUI lách — nó không nội suy con số mà cuộn từng chữ số như đồng hồ cơ. Tương tự .symbolEffect(.replace) morph giữa hai SF Symbol thay vì đổi phựt.")
    }
  }
}

// MARK: - Danh mục transition

private enum TransitionKind: String, CaseIterable, Identifiable {
  case opacity
  case scale
  case slide
  case moveTop = "move(.top)"
  case push = "push(.bottom)"
  case blurReplace = "blurReplace"
  case combined = "scale + opacity"
  case asymmetric

  var id: Self { self }

  var transition: AnyTransition {
    switch self {
    case .opacity:
      // Mặc định của SwiftUI khi bạn không viết gì.
      .opacity
    case .scale:
      // Phình ra từ tâm. Thêm anchor: để đổi gốc phình.
      .scale
    case .slide:
      // Vào từ leading, ra về trailing (đã kèm sẵn fade).
      .slide
    case .moveTop:
      // Trượt qua mép trên. KHÔNG kèm fade → thường combine thêm .opacity.
      .move(edge: .top)
    case .push:
      // iOS 17: view cũ bị view mới đẩy đi, hai bên chuyển động cùng lúc.
      .push(from: .bottom)
    case .blurReplace:
      // iOS 17: mờ nhoè rồi hiện rõ — rất hợp khi đổi nội dung tại chỗ.
      // BlurReplaceTransition là kiểu conform `Transition` (protocol mới của
      // iOS 17), không phải static member của AnyTransition → phải bọc lại.
      AnyTransition(.blurReplace)
    case .combined:
      // Ghép nhiều transition chạy song song.
      .scale.combined(with: .opacity)
    case .asymmetric:
      // Vào một đằng, ra một nẻo.
      .asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .opacity
      )
    }
  }
}

#Preview {
  NavigationStack {
    AnimationTransitionsScreen()
  }
}
