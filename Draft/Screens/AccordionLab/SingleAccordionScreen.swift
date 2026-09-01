//
//  SingleAccordionScreen.swift
//  Draft
//
//  Mục 2 của Accordion Lab — tự dựng MỘT accordion.
//
//  Toàn bộ cơ chế gói trong bốn dòng:
//
//      @State private var isExpanded = false        1. nhớ trạng thái
//      withAnimation { isExpanded.toggle() }        2. đổi trạng thái
//      if isExpanded { body }                       3. thêm/bớt view thật
//      .rotationEffect(isExpanded ? 180 : 0)        4. xoay chevron
//
//  Ba dòng đầu là bắt buộc, dòng thứ tư là trang trí. Phần còn lại của file
//  chỉ để CHỨNG MINH vì sao mấy modifier quanh nó không phải thừa: mỗi công
//  tắc trên màn tắt đi một cái, và tắt cái nào hỏng cái đó.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  VÌ SAO `if` CHỨ KHÔNG PHẢI `.opacity(0)` HAY `.frame(height: 0)`
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `if` là THÊM/BỚT view khỏi cây. Body không tồn tại lúc đóng, nên nó không
//  chiếm chỗ, không tính layout, không chạy `onAppear`. Giấu bằng `.opacity(0)`
//  thì view vẫn còn đó và vẫn chiếm nguyên chiều cao — accordion sẽ không bao
//  giờ co lại.
//
//  Đổi lại, vì view bị bớt đi thật, SwiftUI phải biết "bớt thì trông thế nào" —
//  đó là việc của `transition`. Mặc định là `.opacity`, nên body FADE ra chứ
//  không trượt. Cái trượt mà mắt thấy là do CHIỀU CAO của VStack đổi.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  TRANSITION CHỈ CHẠY KHI CÓ ANIMATION
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `.transition(...)` không tự kích hoạt. Nó chỉ mô tả "nếu lần thêm/bớt này
//  được animate thì animate kiểu gì". Không có `withAnimation` bọc chỗ đổi
//  state thì transition đứng yên — tắt công tắc "withAnimation" bên dưới để
//  thấy: đổi transition kiểu gì cũng không khác gì nhau.
//

import SwiftUI

struct SingleAccordionScreen: View {
  @State private var clipsBody = true
  @State private var animated = true
  @State private var transition: BodyTransition = .opacity
  @State private var duration: Double = 0.25

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(
          """
          Bấm vào header để mở. Rồi tắt từng công tắc bên dưới và bấm lại — \
          mỗi công tắc tương ứng một modifier mà người mới hay bỏ quên.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)

        AccordionItem(
          title: "Accordion Item #1",
          content: Self.sample,
          clipsBody: clipsBody,
          animated: animated,
          bodyTransition: transition,
          duration: duration
        )

        controls

        notes
      }
      .padding(20)
    }
    .navigationTitle("2 · Một cái đơn lẻ")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Công tắc

  private var controls: some View {
    VStack(alignment: .leading, spacing: 16) {
      Toggle("clipShape — cắt phần tràn", isOn: $clipsBody)
      Toggle("withAnimation — gói chỗ đổi state", isOn: $animated)

      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("tốc độ co giãn")
          Spacer()
          // String(format:) để chốt 2 chữ số và luôn ra dấu CHẤM. Nội suy
          // thẳng `\(duration)` thì ra nguyên đuôi thập phân dài của slider
          // (0.7307692307692307); còn `.formatted()` thì theo locale — máy để
          // tiếng Việt cho ra "0,73".
          Text(verbatim: String(format: "%.2fs", duration))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)

        Slider(value: $duration, in: 0.05...2)
          // Không có withAnimation thì mọi con số ở đây đều vô nghĩa.
          .disabled(!animated)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("transition của body")
          .font(.subheadline)
        Picker("transition", selection: $transition) {
          ForEach(BodyTransition.allCases) { option in
            Text(option.label).tag(option)
          }
        }
        .pickerStyle(.segmented)
      }
    }
    .font(.subheadline)
  }

  private var notes: some View {
    VStack(alignment: .leading, spacing: 12) {
      Note(
        "clipShape tắt",
        "Lúc ĐÓNG lại: khung co ngay còn chữ thì fade từ từ, nên chữ tràn ra ngoài viền. Bootstrap giấu chỗ này bằng overflow: hidden."
      )
      Note(
        "withAnimation tắt",
        "Không chỉ mất phần giãn — chevron cũng nhảy 180° tức thì, và transition chọn kiểu gì cũng vô nghĩa."
      )
      Note(
        "kéo chậm ra ~1.5s",
        "Cách nhìn rõ nhất mọi thứ ở trên: chậm lại rồi tắt clipShape, sẽ thấy hẳn chữ nằm ngoài viền trong lúc khung co."
      )
      Note(
        "transition = none",
        "Body hiện ra nguyên khối ngay từ frame đầu, trong khi khung vẫn đang giãn. Đây là mặc định NẾU bạn viết .transition(.identity)."
      )
    }
  }

  private func Note(_ title: LocalizedStringKey, _ body: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.caption.weight(.semibold))
      Text(body).font(.caption).foregroundStyle(.secondary)
    }
  }

  static let sample = """
    This is the first item's accordion body. It is shown by default, until the \
    collapse plugin adds the appropriate classes that we use to style each element.
    """
}

// MARK: - Accordion

private struct AccordionItem: View {
  let title: String
  let content: String

  /// Ba tham số dưới đây chỉ tồn tại để tắt/bật cho lab. Bản dùng thật không
  /// cần chúng: cứ clip, cứ animate, transition để mặc định.
  var clipsBody = true
  var animated = true
  var bodyTransition: BodyTransition = .opacity
  var duration: Double = 0.25

  /// Cả accordion chỉ nhớ đúng một bit. Vì nó là `private @State` nằm TRONG
  /// row, không ai bên ngoài đọc được — đó là lý do mục 4 (single-open) không
  /// thể dùng lại y nguyên struct này.
  @State private var isExpanded = false

  var body: some View {
    // spacing: 0 — có spacing thì lúc đóng vẫn thừa một khoảng trắng dưới
    // header, vì VStack đo khoảng cách kể cả khi chỉ còn một con.
    VStack(spacing: 0) {
      header

      if isExpanded {
        VStack(alignment: .leading, spacing: 0) {
          Divider()

          Text(content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        // Đặt trên chính view BỊ THÊM/BỚT, không phải trên VStack cha —
        // đặt trên cha thì cha có bị bớt đâu mà transition.
        .transition(bodyTransition.value)
      }
    }
    .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: 8))
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color(uiColor: .separator), lineWidth: 1)
    }
    // Luôn gọi `.clipShape`, chỉ đổi HÌNH truyền vào — nhờ vậy chuỗi modifier
    // không đổi, view giữ nguyên identity và không bị reset `isExpanded` mỗi
    // lần bạn gạt công tắc. Bản dùng thật chỉ cần `.clipShape(.rect(cornerRadius: 8))`.
    .clipShape(clipsBody ? AnyShape(.rect(cornerRadius: 8)) : AnyShape(Unclipped()))
  }

  private var header: some View {
    Button {
      if animated {
        // Gói MỘT lần là cả chiều cao lẫn góc xoay cùng chạy, vì cả hai đều
        // đọc `isExpanded`. Không cần `.animation()` rải rác từng chỗ.
        // `.snappy` là spring, nên `duration` KHÔNG phải "chạy đúng ngần này
        // giây rồi dừng" như `.easeInOut(duration:)`. Nó là perceptual
        // duration — nhịp cảm nhận được; lò xo vẫn còn rung nhẹ sau mốc đó.
        withAnimation(.snappy(duration: duration)) {
          isExpanded.toggle()
        }
      } else {
        isExpanded.toggle()
      }
    } label: {
      HStack {
        Text(title)
          .fontWeight(.medium)

        Spacer()

        // Xoay chứ không đổi tên icon: đổi `chevron.down` ↔ `chevron.up` là
        // thay view khác, SwiftUI không nội suy được giữa hai icon nên nó nháy.
        Image(systemName: "chevron.down")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
          .rotationEffect(.degrees(isExpanded ? 180 : 0))
      }
      .padding(16)
      // Không có dòng này thì khoảng trống giữa title và chevron không ăn tap.
      .contentShape(.rect)
    }
    // Thiếu .plain thì cả header bị tô màu accent và nhấp nháy khi bấm.
    .buttonStyle(.plain)
    .foregroundStyle(.primary)
  }
}

// MARK: - Phụ trợ cho lab

private enum BodyTransition: String, CaseIterable, Identifiable {
  case opacity, slide, blur, none

  var id: String { rawValue }

  var label: String {
    switch self {
    case .opacity: return "opacity"
    case .slide: return "slide"
    case .blur: return "blur"
    case .none: return "none"
    }
  }

  var value: AnyTransition {
    switch self {
    case .opacity: return .opacity                                    // mặc định của SwiftUI
    case .slide: return .move(edge: .top).combined(with: .opacity)
    // `.blurReplace` là `Transition` (protocol mới của iOS 17), không phải
    // static member của `AnyTransition` — phải bọc qua init.
    case .blur: return AnyTransition(.blurReplace)
    case .none: return .identity
    }
  }
}

/// Hình to hơn khung rất nhiều → `.clipShape` không cắt được gì. Dùng để TẮT
/// clipping mà vẫn giữ nguyên chuỗi modifier.
private struct Unclipped: Shape {
  func path(in rect: CGRect) -> Path {
    Path(rect.insetBy(dx: -2000, dy: -2000))
  }
}

#Preview {
  NavigationStack {
    SingleAccordionScreen()
  }
}
