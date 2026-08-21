//
//  AnimationBasicsScreen.swift
//  Draft
//
//  Bước 1 — SwiftUI animate GIÁ TRỊ, không animate view.
//
//  Ba cách kích hoạt (theo tài liệu Apple):
//    • withAnimation { state = ... }   → gắn vào SỰ THAY ĐỔI STATE (transaction)
//    • .animation(_:value:)            → gắn vào MỘT VIEW cụ thể
//    • $binding.animation(_:)          → gắn vào ĐƯỜNG GHI state
//

import SwiftUI

struct AnimationBasicsScreen: View {
  // State duy nhất điều khiển mọi thứ trong màn này.
  @State private var isBig = false

  // Đếm số lần animation báo "xong" (mục ⑤).
  @State private var finishedCount = 0
  @State private var isMoved = false

  // Mục ② — hai Toggle giống hệt nhau, khác mỗi binding.
  @State private var isOnPlain = false
  @State private var isOnAnimated = false
  @State private var sliderValue: Double = 0

  // Mục ③ — kéo dài animation ra để mắt kịp thấy phần "ở giữa".
  @State private var demoDuration: Double = 0.6

  var body: some View {
    List {
      whoAnimatesSection
      bindingSection
      animatableSection
      overrideSection
      completionSection
    }
    .navigationTitle("Animation Basics")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - ① Ai animate? Transaction vs modifier

  private var whoAnimatesSection: some View {
    Section {
      HStack(spacing: 32) {
        labeledBox("A\nkhông modifier") {
          RoundedRectangle(cornerRadius: 12)
            .fill(.orange)
            .frame(width: 44, height: 44)
            .scaleEffect(isBig ? 1.6 : 1)
          // Không có .animation ở đây. A chỉ nhúc nhích khi
          // sự thay đổi state được bọc trong withAnimation.
        }

        labeledBox("B\n.animation(value:)") {
          RoundedRectangle(cornerRadius: 12)
            .fill(.blue)
            .frame(width: 44, height: 44)
            .scaleEffect(isBig ? 1.6 : 1)
            .animation(.snappy, value: isBig)
          // B tự canh `isBig`. Ai đổi state, đổi kiểu gì, B vẫn snappy.
          // .snappy — nảy nhẹ, dứt khoát (hợp cho tap/toggle)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)

      Button("Đổi state trần (không animation)") {
        isBig.toggle()                        // A nhảy cóc, B vẫn mượt
      }

      Button("withAnimation(.easeInOut 1.5s)") {
        withAnimation(.easeInOut(duration: 1.5)) {
          isBig.toggle()                      // A chạy chậm 1.5s...
        }
      }
    } header: {
      Text("① Cách 1 & 2: transaction vs modifier")
    } footer: {
      Text("""
      Nút 1: A nhảy tức thì, B vẫn mượt → .animation(_:value:) không cần ai cho phép.
      Nút 2: A bò chậm 1.5 giây, còn B vẫn snappy → animation gắn tại view GHI ĐÈ transaction từ withAnimation.
      """)
    }
  }

  // MARK: - ② Cách 3: animation gắn vào chính cái Binding

  private var bindingSection: some View {
    Section {
      // Toggle thường: nó tự gọi setter của binding, mình KHÔNG có
      // chỗ nào để chèn withAnimation vào.
      Toggle("Binding trần", isOn: $isOnPlain)
      indicator(isOn: isOnPlain, color: .orange)

      // Cùng một Toggle, nhưng binding đã được "tẩm" animation:
      // mọi lượt GHI đi qua nó đều tự động bọc trong transaction.
      Toggle("$isOn.animation(.bouncy)", isOn: $isOnAnimated.animation(.bouncy))
      indicator(isOn: isOnAnimated, color: .blue)

      VStack(alignment: .leading, spacing: 8) {
        // Với Slider thì .animation(_:) trên binding còn làm việc thứ hai:
        // làm mượt cả những bước nhảy do người dùng kéo nhanh.
        Slider(value: $sliderValue.animation(.smooth), in: 0...1)
        Capsule()
          .fill(.tint)
          .frame(width: 40 + sliderValue * 120, height: 24)
      }
      .padding(.vertical, 4)
    } header: {
      Text("② Cách 3: Binding.animation(_:)")
    } footer: {
      Text("""
      Lý do nó tồn tại: hai cách trên đòi bạn phải sở hữu ĐOẠN CODE ĐỔI STATE (withAnimation) hoặc VIEW BỊ ĐỔI (.animation(value:)). Với Toggle, Slider, Picker, TextField thì việc ghi state xảy ra BÊN TRONG control của SwiftUI — không có chỗ nào cho bạn đặt withAnimation. Gắn vào binding là cách chen vào giữa.

      Cơ chế: `$x.animation(.bouncy)` trả về một Binding mới, setter của nó chính là withAnimation(.bouncy) { x = newValue }. Nên nó lan ra TOÀN BỘ view phụ thuộc x, giống hệt cách 1 — khác cách 2 vốn chỉ ảnh hưởng đúng một view.
      """)
    }
  }

  // Chấm tròn phản ứng theo state, cố tình đặt XA cái Toggle
  // để thấy animation lan tới đây mà không cần khai báo gì thêm.
  private func indicator(isOn: Bool, color: Color) -> some View {
    HStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(isOn ? color : .gray.opacity(0.3))
        .frame(width: 44, height: 44)
        .rotationEffect(.degrees(isOn ? 45 : 0))
        .offset(x: isOn ? 120 : 0)
      Spacer()
    }
    .frame(height: 60)
  }

  // MARK: - ③ Giá trị nào nội suy được?

  private var animatableSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 18) {
        // ✅ Kinh điển: một CGFloat, nội suy 1.0 → 1.07 → … → 2.0
        demo("✅ scaleEffect — CGFloat") {
          Text("Xin chào")
            .font(.system(size: 20))
            .scaleEffect(isBig ? 2 : 1, anchor: .leading)
        }

        // ✅ Cỡ chữ CŨNG nội suy được. Nhiều tài liệu cũ bảo là không —
        //    đo trên iOS 18.6 thì có, chữ lớn dần từng frame.
        demo("✅ .font(.system(size:)) — cỡ chữ") {
          Text("Xin chào")
            .font(.system(size: isBig ? 40 : 20))
        }

        // ❌ Đổi KIỂU chữ: không có "nửa serif nửa sans" → SwiftUI chồng mờ.
        demo("❌ .fontDesign — kiểu chữ") {
          Text("Xin chào")
            .font(.system(size: 28))
            .fontDesign(isBig ? .serif : .default)
        }

        // ❌ Đổi NỘI DUNG: hai chuỗi khác nhau, cũng chỉ chồng mờ được.
        demo("❌ Text đổi nội dung") {
          Text(isBig ? "Tạm biệt" : "Xin chào")
            .font(.system(size: 28))
        }
      }
      .padding(.vertical, 8)

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text("duration")
          Spacer()
          Text(demoDuration, format: .number.precision(.fractionLength(1)))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        // Kéo lên 3–4 giây rồi bấm Toggle: hai ô ✅ bò từ từ,
        // hai ô ❌ đã đổi xong ngay từ frame đầu.
        Slider(value: $demoDuration, in: 0.2...5)
      }
      .padding(.vertical, 4)

      Button("Toggle") { isBig.toggle() }
    } header: {
      Text("③ Không phải cái gì cũng nội suy được")
    } footer: {
      Text("""
      Kéo duration lên 4–5 giây rồi bấm Toggle. Ở tốc độ thường (0.6s) mắt không phân biệt nổi, cả bốn ô trông y như nhau.

      Ranh giới: giữa hai giá trị có tồn tại "giá trị ở giữa" không?

      ✅ 28.4pt là một cỡ chữ hợp lệ → nội suy được, chữ lớn dần từng frame.

      ❌ Không có kiểu chữ nào nửa serif nửa sans, cũng không có chuỗi nào nằm giữa "Xin chào" và "Tạm biệt". Không nội suy được, SwiftUI CHỒNG MỜ ảnh cũ với ảnh mới trong đúng khoảng thời gian đó — chạy chậm sẽ thấy rõ hai chữ đè lên nhau.

      Nên phát biểu cho đủ: animation là nội suy giá trị; chỗ nào không nội suy được thì mặc định lùi về crossfade. contentTransition (bài 3) chính là chỗ bạn chọn hiệu ứng thay cho cái crossfade mặc định đó.

      Cái conform Animatable là các đại lượng số — CGFloat, Double, CGSize, CGPoint, Angle, Color, EdgeInsets, UnitPoint. Kiểu chữ, chuỗi, Bool, Image, enum thì không.
      """)
    }
  }

  // Một ô demo: nội dung + nhãn mô tả.
  private func demo(_ caption: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      content()
        // LƯU Ý: .animation phải nằm ĐÚNG ĐÂY, sát cái Text.
        // Đo bằng video: gắn nó lên VStack bao ngoài 4 ô thì không ô nào
        // animate — cỡ chữ nhảy thẳng từ 20 sang 40 trong một frame.
        .animation(.easeInOut(duration: demoDuration), value: isBig)
        .frame(height: 44, alignment: .leading)
      Text(caption)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - ④ Tắt animation cho một nhánh con

  private var overrideSection: some View {
    Section {
      HStack(spacing: 32) {
        labeledBox("theo\ntransaction") {
          Circle()
            .fill(.green)
            .frame(width: 44, height: 44)
            .offset(x: isMoved ? 40 : -40)
        }

        labeledBox("bị\nkhoá") {
          Circle()
            .fill(.red)
            .frame(width: 44, height: 44)
            .offset(x: isMoved ? 40 : -40)
            .animation(nil, value: isMoved)   // miễn nhiễm với withAnimation
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)

      Button("withAnimation(.bouncy)") {
        withAnimation(.bouncy) { isMoved.toggle() }
      }
    } header: {
      Text("④ .animation(nil, value:) — miễn trừ")
    } footer: {
      Text("Transaction chảy xuống TOÀN BỘ cây view bên dưới chỗ state đổi. Muốn một view nào đó đứng yên tuyệt đối thì gắn .animation(nil, value:) — hữu ích khi một phần UI (badge, số liệu) không nên trượt theo phần còn lại.")
    }
  }

  // MARK: - ⑤ Biết khi nào animation kết thúc

  private var completionSection: some View {
    Section {
      LabeledContent("Số lần chạy xong") {
        Text("\(finishedCount)")
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }

      Button("withAnimation + completion") {
        withAnimation(.easeInOut(duration: 1)) {
          isBig.toggle()
        } completion: {
          finishedCount += 1                  // gọi SAU khi animation dừng hẳn
        }
      }
    } header: {
      Text("⑤ completion (iOS 17+)")
    } footer: {
      Text("Trước iOS 17 phải tự đoán bằng DispatchQueue.asyncAfter(duration) — sai bét với spring vì spring không có duration cố định. Nay dùng completionCriteria: .logicallyComplete (mặc định, kích hoạt khi giá trị đã tới đích) hoặc .removed (đợi cả phần nảy dư tắt hẳn).")
    }
  }

  // MARK: - Helper

  // Bọc một demo box kèm nhãn mô tả bên dưới.
  private func labeledBox(_ caption: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(spacing: 8) {
      content()
        .frame(width: 80, height: 80)         // khung cố định để scale không đẩy layout
      Text(caption)
        .font(.caption2)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  NavigationStack {
    AnimationBasicsScreen()
  }
}
