//
//  SensoryFeedbackScreen.swift
//  Draft
//
//  Bước 2 — .sensoryFeedback(_:trigger:)
//
//  Toàn bộ màn này chỉ dùng SwiftUI thuần: không import UIKit,
//  không tạo generator nào. Chỉ có state + modifier.
//

import SwiftUI

struct SensoryFeedbackScreen: View {
  // ① Loại haptic sắp phát. Đổi trước, rồi mới đụng tới trigger.
  @State private var current: SensoryFeedback = .selection
  // ② Bộ đếm đóng vai "sự kiện". Tăng dần nên giá trị luôn mới.
  @State private var tapCount = 0

  // Cường độ cho nhóm .impact (0…1). Không ảnh hưởng notification/selection.
  @State private var intensity: Double = 1.0

  // Demo cái bẫy: trigger kiểu Bool bị gán lại cùng giá trị.
  @State private var boolTrigger = false

  // Demo variant có condition: chỉ rung khi giá trị TĂNG.
  @State private var level = 0

  var body: some View {
    List {
      notificationSection
      selectionSection
      impactSection
      semanticSection
      triggerTrapSection
      conditionSection
    }
    .navigationTitle("SensoryFeedback")
    .navigationBarTitleDisplayMode(.inline)

    // ③ MỘT modifier phục vụ cho toàn bộ nút bên trên.
    //    Mỗi lần tapCount đổi, SwiftUI đọc `current` tại thời điểm render
    //    và phát đúng loại haptic đó.
    .sensoryFeedback(current, trigger: tapCount)

    // Trigger Bool riêng — để thấy lần bấm thứ 2 trở đi im lặng.
    .sensoryFeedback(.success, trigger: boolTrigger)

    // Variant closure: trả về nil nghĩa là "không rung".
    .sensoryFeedback(trigger: level) { old, new in
      new > old ? .increase : nil
    }
  }

  // MARK: - Notification: báo kết quả một tác vụ

  private var notificationSection: some View {
    Section {
      row("success", .success)
      row("warning", .warning)
      row("error", .error)
    } header: {
      Text("Notification")
    } footer: {
      Text("UINotificationFeedbackGenerator. Ba nhịp có tiết tấu riêng — dùng để báo KẾT QUẢ, không dùng cho thao tác thường.")
    }
  }

  // MARK: - Selection: lướt qua từng nấc rời rạc

  private var selectionSection: some View {
    Section {
      row("selection", .selection)
    } header: {
      Text("Selection")
    } footer: {
      Text("UISelectionFeedbackGenerator. Cực nhẹ, thiết kế để bắn liên tục khi người dùng lướt qua từng nấc (Picker, slider có step).")
    }
  }

  // MARK: - Impact: hai vật va vào nhau

  private var impactSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text("intensity")
          Spacer()
          Text(intensity, format: .number.precision(.fractionLength(2)))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        Slider(value: $intensity, in: 0...1)
      }
      .padding(.vertical, 4)

      row("impact(weight: .light)", .impact(weight: .light, intensity: intensity))
      row("impact(weight: .medium)", .impact(weight: .medium, intensity: intensity))
      row("impact(weight: .heavy)", .impact(weight: .heavy, intensity: intensity))

      row("impact(flexibility: .rigid)", .impact(flexibility: .rigid, intensity: intensity))
      row("impact(flexibility: .solid)", .impact(flexibility: .solid, intensity: intensity))
      row("impact(flexibility: .soft)", .impact(flexibility: .soft, intensity: intensity))
    } header: {
      Text("Impact")
    } footer: {
      Text("weight = nặng/nhẹ, flexibility = cứng/mềm. Hai TRỤC KHÁC NHAU, không phải hai tên gọi của cùng một thang. Kéo intensity về 0 rồi bấm lại để thấy khác biệt.")
    }
  }

  // MARK: - Nhóm ngữ nghĩa: mô tả Ý NGHĨA, không mô tả cảm giác

  private var semanticSection: some View {
    Section {
      row("increase", .increase)
      row("decrease", .decrease)
      row("start", .start)
      row("stop", .stop)
      row("alignment", .alignment)
      row("levelChange", .levelChange)
    } header: {
      Text("Semantic")
    } footer: {
      Text("Cross-platform. Apple không công bố chúng map xuống generator nào trên iOS — bạn khai báo ý nghĩa, hệ thống chọn cảm giác. Dùng khi bạn chỉ biết 'chuyện gì vừa xảy ra' chứ chưa quyết cảm giác.")
    }
  }

  // MARK: - Cái bẫy trigger

  private var triggerTrapSection: some View {
    Section {
      Button {
        boolTrigger = true          // Lần 2 trở đi: true == true → im lặng
      } label: {
        LabeledContent("Bool: gán true") {
          Text(boolTrigger ? "true" : "false")
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
      }

      Button("Reset về false") {
        boolTrigger = false         // Lần này cũng rung! false != true
      }
      .disabled(!boolTrigger)

      Button {
        current = .success
        tapCount += 1               // Luôn khác giá trị cũ → luôn rung
      } label: {
        LabeledContent("Counter: tapCount += 1") {
          Text("\(tapCount)")
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
      }
    } header: {
      Text("Bẫy: trigger là STATE, không phải EVENT")
    } footer: {
      Text("Nút Bool chỉ rung ở lần bấm ĐẦU. SwiftUI so oldValue != newValue, gán lại cùng giá trị thì không có gì đổi. Reset cũng rung, vì false != true — đó là bằng chứng nó so sánh chứ không nhìn 'true nghĩa là xảy ra'.")
    }
  }

  // MARK: - Variant closure: lọc theo hướng thay đổi

  private var conditionSection: some View {
    Section {
      Stepper {
        LabeledContent("level") {
          Text("\(level)")
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
      } onIncrement: {
        level += 1
      } onDecrement: {
        level -= 1
      }
    } header: {
      Text("Có điều kiện")
    } footer: {
      Text("Chỉ rung khi TĂNG. Closure nhận (old, new) và trả về SensoryFeedback? — trả nil là không rung. Bấm giảm để nghe sự im lặng.")
    }
  }

  // MARK: - Helper

  // Một nút: đổi loại haptic rồi bắn trigger.
  private func row(_ name: String, _ feedback: SensoryFeedback) -> some View {
    Button {
      current = feedback     // ① phải trước
      tapCount += 1          // ② mới tới
    } label: {
      Text(name)
        .font(.system(.body, design: .monospaced))
    }
  }
}

#Preview {
  NavigationStack {
    SensoryFeedbackScreen()
  }
}
