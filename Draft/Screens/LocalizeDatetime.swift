//
//  LocalizeDaytime.swift
//  Draft
//
//  Created by Lam Tran  on 17/6/26.
//

import SwiftUI

struct LocalizeDatetime: View {

  /// Chuỗi server thường trả về: ISO 8601, UTC ("Z"), có fractional seconds.
  private let datetime = "2026-06-17T13:28:00.233091Z"

  /// Ngôn ngữ đang chọn qua toggle. Được truyền tường minh vào các format style
  /// và đẩy xuống environment cho cả cây view.
  @State private var locale = Locale(identifier: "vi_VN")

  var body: some View {
    List {
      languageSection
      parsingSection
      modernFormatStyleSection
      dateFormatterSection
      localeAndTimeZoneSection
      relativeSection
      componentsSection
    }
    // Đẩy locale xuống environment: ảnh hưởng `Text(date, format:)` và
    // NSLocalizedString. Lưu ý: KHÔNG ảnh hưởng `date.formatted()` -> String.
    .environment(\.locale, locale)
  }

  // MARK: - Toggle ngôn ngữ

  @ViewBuilder
  private var languageSection: some View {
    Section {
      Picker("Ngôn ngữ hiển thị", selection: $locale) {
        Text("Tiếng Việt").tag(Locale(identifier: "vi_VN"))
        Text("English").tag(Locale(identifier: "en_US"))
      }
      .pickerStyle(.segmented)
    } header: {
      Text("Ngôn ngữ")
    } footer: {
      Text("Locale đang chọn: \(locale.identifier)\nLocale.current: \(Locale.current.identifier)")
    }
  }

  // MARK: - Parsing

  /// ISO8601DateFormatter: chuẩn nhất để parse chuỗi server.
  /// Bắt buộc bật `.withFractionalSeconds` vì chuỗi có ".233091".
  private var iso8601Date: Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: datetime)
  }

  /// Date đã parse, dùng cho các section bên dưới.
  private var date: Date { iso8601Date ?? .now }

  @ViewBuilder
  private var parsingSection: some View {
    Section("1 · Parsing chuỗi ISO 8601") {
      row("Input", datetime)
      row("ISO8601DateFormatter", iso8601Date.map(String.init(describing:)) ?? "nil ❌")
    }
  }

  // MARK: - Modern: 2. Date.FormatStyle (iOS 15+)

  @ViewBuilder
  private var modernFormatStyleSection: some View {
    Section("2 · Date.FormatStyle (khuyến nghị)") {
      // ⚠️ Bẫy: .formatted() trần dùng Locale.current -> KHÔNG đổi theo toggle.
      row(".formatted() (dùng Locale.current ⚠️)", date.formatted())
      
      row(".formatted(.dateTime.locale(locale))", date.formatted(.dateTime.locale(locale)))

      row(
        "date: .abbreviated, time: .shortened",
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale))
      )
      row(
        "date: .complete, time: .omitted",
        date.formatted(Date.FormatStyle(date: .complete, time: .omitted).locale(locale))
      )

      row(
        ".dateTime tuỳ biến (giống với format trên)",
        date.formatted(
          .dateTime.weekday(.wide).month(.wide).day().year().locale(locale)
        )
      )

      row(
        ".dateTime tuỳ biến",
        date.formatted(
          .dateTime.year().month(.wide).day().hour().minute().locale(locale)
        )
      )

      row("Chỉ giờ", date.formatted(.dateTime.hour().minute().second().locale(locale)))
    }
  }

  // MARK: - Classic: 3. DateFormatter (custom pattern)

  @ViewBuilder
  private var dateFormatterSection: some View {
    Section("3 · DateFormatter (pattern tuỳ chỉnh)") {
      row("dd/MM/yyyy HH:mm", custom(format: "dd/MM/yyyy HH:mm"))
      row("EEE, d MMM yyyy", custom(format: "EEE, d MMM yyyy"))
      row("h:mm a", custom(format: "h:mm a"))
      row("style: .medium / .short",
          styled(date: .medium, time: .short))
    }
  }

  // MARK: - 4. Locale & TimeZone

  @ViewBuilder
  private var localeAndTimeZoneSection: some View {
    Section("4 · Ép locale tường minh (độc lập với toggle)") {
      row("vi_VN", date.formatted(
        .dateTime.weekday(.wide).day().month().year().hour().minute()
          .locale(Locale(identifier: "vi_VN"))))
      row("en_US", date.formatted(
        .dateTime.weekday(.wide).day().month().year().hour().minute()
          .locale(Locale(identifier: "en_US"))))
    }
  }

  // MARK: - Relative

  @ViewBuilder
  private var relativeSection: some View {
    Section("5 · Tương đối (relative)") {
      row(".relative(.named)", date.formatted(.relative(presentation: .named).locale(locale)))
      row("RelativeDateTimeFormatter", relative())
    }
  }

  // MARK: - Components

  @ViewBuilder
  private var componentsSection: some View {
    Section("6 · Tách thành phần (Calendar)") {
      let c = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute, .second], from: date)
      row("year", "\(c.year ?? 0)")
      row("month", "\(c.month ?? 0)")
      row("day", "\(c.day ?? 0)")
      row("hour", "\(c.hour ?? 0)")
      row("minute", "\(c.minute ?? 0)")
    }
  }

  // MARK: - Helpers

  /// Pattern cố định -> luôn khoá en_US_POSIX, KHÔNG đổi theo toggle (cố ý).
  private func custom(format: String) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = format
    return f.string(from: date)
  }

  private func styled(
    date dateStyle: DateFormatter.Style,
    time timeStyle: DateFormatter.Style
  ) -> String {
    let f = DateFormatter()
    f.locale = locale
    f.dateStyle = dateStyle
    f.timeStyle = timeStyle
    return f.string(from: date)
  }

  private func relative() -> String {
    let f = RelativeDateTimeFormatter()
    f.locale = locale
    f.unitsStyle = .full
    return f.localizedString(for: date, relativeTo: .now)
  }

  private func row(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.callout.monospaced())
        .textSelection(.enabled)
    }
  }
}

#Preview {
  NavigationStack {
    LocalizeDatetime()
  }
}
