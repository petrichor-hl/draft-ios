import SwiftUI

struct AppearanceScreen: View {
    @AppStorage(StorageKeys.appAppearance) private var appearance: AppAppearance = .system
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            Section {
                LabeledContent("Appearance hiện tại") {
                    Label(
                        colorScheme == .dark ? "Dark" : "Light",
                        systemImage: colorScheme == .dark ? "moon.fill" : "sun.max.fill"
                    )
                    .foregroundStyle(Color.Semantic.Text.secondary)
                }
                .listRowBackground(Color.Semantic.Background.surface)
            } header: {
                Text("Chế độ hiển thị")
            } footer: {
                Text("Đổi chế độ bằng menu ở góc trên. System theo cài đặt thiết bị. Lựa chọn được lưu và áp dụng cho toàn app.")
                    .foregroundStyle(Color.Semantic.Text.secondary)
            }
            
            Section {
                if #available(iOS 26.0, *) {
                    previewCard
                        .listRowInsets(.all, 0)
                        .listRowBackground(Color.clear)
                } else {
                    previewCard
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text("Xem trước")
            }
            
            Section {
                SemanticColorRow(
                    name: "App", assetPath: "SemanticColor/Background/App",
                    color: Color.Semantic.Background.app
                )
                SemanticColorRow(
                    name: "Surface", assetPath: "SemanticColor/Background/Surface",
                    color: Color.Semantic.Background.surface
                )
            } header: {
                Text("Background")
            }
            
            Section {
                SemanticColorRow(
                    name: "Primary", assetPath: "SemanticColor/Text/Primary",
                    color: Color.Semantic.Text.primary
                )
                SemanticColorRow(
                    name: "Secondary", assetPath: "SemanticColor/Text/Secondary",
                    color: Color.Semantic.Text.secondary
                )
            } header: {
                Text("Text")
            }
            
            Section {
                SemanticColorRow(
                    name: "PrimaryBackground", assetPath: "SemanticColor/Action/PrimaryBackground",
                    color: Color.Semantic.Action.primaryBackground
                )
                SemanticColorRow(
                    name: "PrimaryForeground", assetPath: "SemanticColor/Action/PrimaryForeground",
                    color: Color.Semantic.Action.primaryForeground
                )
            } header: {
                Text("Action")
            } footer: {
                Text("Mỗi ô màu và mã HEX hiển thị variant đang dùng. Đổi Light/Dark để so sánh.")
            }
        }
        .foregroundStyle(Color.Semantic.Text.primary)
        .scrollContentBackground(.hidden)
        .background(Color.Semantic.Background.app)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "circle.lefthalf.filled")
                }
                .accessibilityLabel("Appearance")
            }
        }
    }
    
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Semantic colors", systemImage: "paintpalette.fill")
                .font(.headline)
                .foregroundStyle(Color.Semantic.Text.primary)
            
            Text("- Nền card dùng Background/Surface.\n- Tiêu đề dùng Text/Primary.\n- Mô tả dùng Text/Secondary.")
                .font(.subheadline)
                .foregroundStyle(Color.Semantic.Text.secondary)
            
            Button {
                
            } label: {
                Label("Primary action", systemImage: "hand.tap")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.Semantic.Action.primaryForeground)
                    .background(
                        Color.Semantic.Action.primaryBackground,
                        in: .rect(cornerRadius: 12)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.Semantic.Background.surface, in: .rect(cornerRadius: 20))
    }
}

private struct SemanticColorRow: View {
    @Environment(\.self) private var environment
    
    let name: String
    let assetPath: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.Semantic.Text.secondary.opacity(0.3), lineWidth: 1)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.Semantic.Text.primary)
                
                Text(assetPath)
                    .font(.caption)
                    .foregroundStyle(Color.Semantic.Text.secondary)
                
                Text(hexValue)
                    .font(.caption.monospaced())
                    .foregroundStyle(Color.Semantic.Text.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.Semantic.Background.surface)
    }
    
    private var hexValue: String {
        let resolved = color.resolve(in: environment)
        let components = [resolved.red, resolved.green, resolved.blue].map {
            Int((min(max($0, 0), 1) * 255).rounded())
        }
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }
}
