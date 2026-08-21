//
//  SheetEventLog.swift
//  Draft
//
//  Hạ tầng dùng chung cho DoubleSheetLab: nhật ký sự kiện + view sheet mẫu.
//  Mấu chốt của lab này là *thứ tự thời gian*, nên mọi thứ đều được đóng dấu
//  mốc ms kể từ lúc bắt đầu kịch bản.
//

import SwiftUI

struct SheetLogEntry: Identifiable {
  let id = UUID()
  let text: String
}

@Observable
final class SheetEventLog {
  private(set) var entries: [SheetLogEntry] = []
  private var start = Date()

  /// Mới nhất nằm trên cùng để không phải cuộn.
  func add(_ text: String) {
    let ms = Int(Date().timeIntervalSince(start) * 1000)
    entries.insert(SheetLogEntry(text: String(format: "%5d ms  %@", ms, text)), at: 0)
  }

  /// Gọi ở đầu mỗi kịch bản để mốc thời gian đọc được.
  func reset() {
    entries.removeAll()
    start = Date()
  }
}

// MARK: - Views dùng chung

/// Nội dung sheet mẫu. `onAppear`/`onDisappear` là thứ cho ta biết sheet có
/// thật sự lên màn hình hay bị SwiftUI nuốt mất.
struct LabSheetView: View {
  let name: String
  let tint: Color
  let log: SheetEventLog
  let onClose: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Text(name)
        .font(.system(size: 96, weight: .bold, design: .rounded))
        .foregroundStyle(tint)

      Text("Sheet \(name)")
        .font(.headline)

      Button("Đóng", action: onClose)
        .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(tint.opacity(0.15))
    .presentationDetents([.medium])
    .onAppear { log.add("Sheet \(name) — onAppear") }
    .onDisappear { log.add("Sheet \(name) — onDisappear") }
  }
}

/// Bản cho .fullScreenCover: không detent, không vuốt để đóng — nút Đóng là
/// lối ra duy nhất, nên nó phải luôn hiện diện.
struct LabCoverView: View {
  let name: String
  let tint: Color
  let log: SheetEventLog
  let onClose: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Text(name)
        .font(.system(size: 96, weight: .bold, design: .rounded))
        .foregroundStyle(tint)

      Text("Cover \(name)")
        .font(.headline)

      Button("Đóng", action: onClose)
        .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(tint.opacity(0.15).ignoresSafeArea())
    .onAppear { log.add("Cover \(name) — onAppear") }
    .onDisappear { log.add("Cover \(name) — onDisappear") }
  }
}

struct SheetEventLogSection: View {
  let log: SheetEventLog

  var body: some View {
    Section {
      if log.entries.isEmpty {
        Text("Chưa có sự kiện nào")
          .foregroundStyle(.secondary)
      } else {
        ForEach(log.entries) { entry in
          Text(entry.text)
            .font(.system(.caption, design: .monospaced))
        }
      }
    } header: {
      HStack {
        Text("Nhật ký")
        Spacer()
        Button("Xoá") { log.reset() }
          .font(.caption)
          .textCase(nil)
      }
    }
  }
}

/// Khối code minh hoạ đặt đầu mỗi màn.
struct SheetSourceSnippet: View {
  let code: String

  var body: some View {
    Text(code)
      .font(.system(.caption, design: .monospaced))
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
