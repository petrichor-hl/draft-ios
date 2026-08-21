//
//  OutsideViewScreen.swift
//  Draft
//
//  Generator F — bắn haptic từ code KHÔNG PHẢI view.
//
//  Đây là lý do thực dụng nhất để vẫn dùng UIKit generator trong app SwiftUI:
//  .sensoryFeedback bắt buộc phải có một @State trong view làm trigger.
//  Khi haptic phát sinh từ tầng logic (ViewModel, Task async, delegate),
//  bạn phải nặn ra một state chỉ để làm cầu nối.
//
//  Màn này chạy CÙNG MỘT tác vụ giả lập bằng hai cách để so sánh.
//

import SwiftUI
import UIKit

struct OutsideViewScreen: View {
  @State private var direct = UploadTask()
  @State private var bridged = BridgedUploadTask()

  var body: some View {
    List {
      directSection
      bridgedSection
      verdictSection
    }
    .navigationTitle("Ngoài view")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - F1. Generator gọi thẳng trong ViewModel

  private var directSection: some View {
    Section {
      progressRow(progress: direct.progress, state: direct.state)

      Button {
        direct.start()
      } label: {
        Label("Chạy — haptic trong ViewModel", systemImage: "play.fill")
      }
      .disabled(direct.isRunning)
    } header: {
      Text("F1. Gọi thẳng")
    } footer: {
      Text("""
        Mỗi 20% một cú impact, kết thúc bằng notification .success hoặc .error (hỏng ngẫu nhiên 1/3 số lần \
        để bạn nghe được cả hai).

        Toàn bộ lệnh haptic nằm trong UploadTask — view không biết haptic tồn tại. Đây là tách lớp đúng: \
        ai biết "chuyện gì vừa xảy ra" thì người đó phát tín hiệu.
        """)
    }
  }

  // MARK: - F2. Cùng tác vụ, nhưng nhồi qua .sensoryFeedback

  private var bridgedSection: some View {
    Section {
      progressRow(progress: bridged.progress, state: bridged.state)

      Button {
        bridged.start()
      } label: {
        Label("Chạy — haptic qua .sensoryFeedback", systemImage: "play.fill")
      }
      .disabled(bridged.isRunning)
    } header: {
      Text("F2. Bắc cầu qua state")
    } footer: {
      Text("""
        Cảm giác y hệt F1. Nhưng để làm được, ViewModel phải phơi ra hai property tồn tại CHỈ ĐỂ \
        làm trigger: milestone (đếm mốc) và outcome (kết quả). Chúng không phục vụ giao diện gì cả.

        Và vì .sensoryFeedback chỉ so oldValue != newValue, `milestone` bắt buộc phải là bộ đếm tăng dần — \
        đúng cái bẫy ở màn SensoryFeedback.
        """)
    }
    // Hai modifier này là toàn bộ "chi phí" của cách làm F2
    .sensoryFeedback(.impact(weight: .medium), trigger: bridged.milestone)
    .sensoryFeedback(trigger: bridged.outcome) { _, new in
      switch new {
      case .success: .success
      case .failure: .error
      case .none: nil
      }
    }
  }

  private var verdictSection: some View {
    Section {
      Label("Quy tắc chọn", systemImage: "signpost.right.fill")
        .foregroundStyle(.secondary)
    } footer: {
      Text("""
        Haptic sinh ra từ TƯƠNG TÁC trong view (chạm, kéo, chọn) → .sensoryFeedback, khai báo gọn hơn.

        Haptic sinh ra từ LOGIC ngoài view (task async, delegate, notification, timer) → generator gọi thẳng. \
        Bắc cầu qua state chỉ tổ đẻ ra property giả và một bẫy đồng bộ.
        """)
    }
  }

  private func progressRow(progress: Double, state: UploadState) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      ProgressView(value: progress)
      HStack {
        Text(progress, format: .percent.precision(.fractionLength(0)))
          .monospacedDigit()
        Spacer()
        switch state {
        case .idle:
          Text("chưa chạy").foregroundStyle(.secondary)
        case .running:
          Text("đang chạy…").foregroundStyle(.orange)
        case .success:
          Label("xong", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        case .failure:
          Label("hỏng", systemImage: "xmark.circle.fill").foregroundStyle(.red)
        }
      }
      .font(.caption)
    }
    .padding(.vertical, 4)
  }
}

enum UploadState {
  case idle, running, success, failure
}

// MARK: - F1: ViewModel tự cầm generator

// Generator là property của class nên sống đúng bằng vòng đời tác vụ —
// prepare() gọi lúc bắt đầu vẫn còn nguyên tác dụng khi mốc đầu tiên tới.
@MainActor
@Observable
final class UploadTask {
  private(set) var progress: Double = 0
  private(set) var state: UploadState = .idle
  var isRunning: Bool { state == .running }

  private let impact = UIImpactFeedbackGenerator(style: .medium)
  private let notification = UINotificationFeedbackGenerator()

  func start() {
    guard !isRunning else { return }
    progress = 0
    state = .running
    impact.prepare()

    Task {
      let willFail = Int.random(in: 0..<3) == 0

      for step in 1...5 {
        try? await Task.sleep(for: .milliseconds(400))
        progress = Double(step) / 5
        impact.impactOccurred()          // ← haptic ngay tại chỗ sự kiện xảy ra
      }

      notification.notificationOccurred(willFail ? .error : .success)
      state = willFail ? .failure : .success
    }
  }
}

// MARK: - F2: cùng logic, nhưng phải phơi state ra cho view

@MainActor
@Observable
final class BridgedUploadTask {
  private(set) var progress: Double = 0
  private(set) var state: UploadState = .idle
  var isRunning: Bool { state == .running }

  // Hai property dưới đây tồn tại CHỈ ĐỂ làm trigger cho .sensoryFeedback.
  // Chúng không vẽ ra pixel nào — đó chính là cái giá của cách làm này.
  private(set) var milestone = 0
  private(set) var outcome: Outcome?

  enum Outcome: Equatable { case success, failure }

  func start() {
    guard !isRunning else { return }
    progress = 0
    outcome = nil
    state = .running

    Task {
      let willFail = Int.random(in: 0..<3) == 0

      for step in 1...5 {
        try? await Task.sleep(for: .milliseconds(400))
        progress = Double(step) / 5
        milestone += 1               // ← phải TĂNG DẦN, gán lại cùng giá trị là im
      }

      outcome = willFail ? .failure : .success
      state = willFail ? .failure : .success
    }
  }
}

#Preview {
  NavigationStack {
    OutsideViewScreen()
  }
}
