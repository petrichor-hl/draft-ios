//
//  LanguagePickerScreen.swift
//  Draft
//
//  UI chọn ngôn ngữ app: Tiếng Việt / English / Español.

import SwiftUI

// MARK: - Model

enum AppLanguage: String, CaseIterable, Identifiable {
  case vietnamese
  case english
  case spanish

  var id: String { rawValue }

  var locale: Locale {
    switch self {
    case .vietnamese: Locale(identifier: "vi_VN")
    case .english: Locale(identifier: "en_US")
    case .spanish: Locale(identifier: "es_ES")
    }
  }

  var nativeLanguageName: String {
    switch self {
    case .vietnamese: "Tiếng Việt"
    case .english: "English"
    case .spanish: "Español"
    }
  }

  var flag: String {
    switch self {
    case .vietnamese: "🇻🇳"
    case .english: "🇺🇸"
    case .spanish: "🇪🇸"
    }
  }
}

// MARK: - Screen

struct LanguagePickerScreen: View {

  @AppStorage(StorageKeys.appLanguage) private var selected: AppLanguage = .vietnamese

  var body: some View {
    List {
      Section {
        ForEach(AppLanguage.allCases) { language in
          languageRow(language)
        }
      } header: {
        Text("Ngôn ngữ")
      } footer: {
        Text("Locale sẽ truyền ở root: \(selected.locale.identifier)")
      }
    }
    .navigationTitle("Chọn ngôn ngữ")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func languageRow(_ language: AppLanguage) -> some View {
    Button {
      withAnimation(.snappy) {
        selected = language
      }
    } label: {
      HStack(spacing: 12) {
        Text(language.flag)
          .font(.title2)

        VStack(alignment: .leading, spacing: 2) {
          Text(language.nativeLanguageName)
            .foregroundStyle(.primary)
          Text(language.locale.identifier)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        if selected == language {
          Image(systemName: "checkmark")
            .font(.body.weight(.semibold))
            .foregroundStyle(.tint)
            .transition(.scale.combined(with: .opacity))
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    LanguagePickerScreen()
  }
}
