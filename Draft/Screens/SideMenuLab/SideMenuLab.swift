import SwiftUI
import UIKit

struct SideMenuLab: View {

  @Environment(AppCoordinator.self) private var coordinator

  @State private var isMenuOpen = false
  @State private var dragTranslation: CGFloat = 0   // độ kéo tạm thời khi chưa nhấc tay
  @State private var selected: MenuItem = .home     // item đang chọn (nguồn sự thật)

  private let edgeThreshold: CGFloat = 16   // Vùng sát cạnh trái dành riêng cho gesture back của hệ thống

  private let menuWidth: CGFloat = 250      // Set cứng chiều rộng của menu -> ổn trên iPhone

  var body: some View {
    let contentOffset = currentOffset()
    let progress = contentOffset / menuWidth

    ZStack(alignment: .leading) {
      // (1) Menu nằm dưới, ghim mép trái, trượt vào từ trái
      SideMenuContent(selected: selected) { item in
        withAnimation(.snappy) {
          selected = item
          isMenuOpen = false        // chọn xong đóng menu
        }
      }
      .frame(width: menuWidth)
      .offset(x: contentOffset - menuWidth)

      // (2) Content bị đẩy sang phải — khung dùng chung, nội dung đổi theo selected
      MainContent(
        title: selected.rawValue,
        isMenuOpen: $isMenuOpen,
        progress: progress,
        onMenu: { withAnimation(.snappy) { isMenuOpen.toggle() } },
        // onBack: { coordinator.pop() }
      ) {
        switch selected {
        case .home:     HomeScreen()
        case .profile:  ProfileScreen()
        case .settings: SettingsScreen()
        }
      }
      .offset(x: contentOffset)
    }
    .simultaneousGesture(dragGesture())
    .background(SwipeBackEnabler())
    .toolbar(.hidden, for: .navigationBar)
  }

  private func currentOffset() -> CGFloat {
    let base = isMenuOpen ? menuWidth : 0
    return min(max(base + dragTranslation, 0), menuWidth)
  }

  private func dragGesture() -> some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        // Chỉ mở menu khi cú kéo bắt đầu ở GIỮA màn hình.
        // Bắt đầu sát cạnh trái (x <= 16) → return → nhường gesture back cho hệ thống.
        guard value.startLocation.x > edgeThreshold else { return }
        dragTranslation = value.translation.width
      }
      .onEnded { value in
        guard value.startLocation.x > edgeThreshold else { return }
        // Dựa vào ĐÀ (predicted) để quyết định mở hẳn hay đóng lại
        let projected = (isMenuOpen ? menuWidth : 0) + value.predictedEndTranslation.width
        withAnimation(.snappy) {
          isMenuOpen = projected > menuWidth / 2
          dragTranslation = 0
        }
      }
  }
}

// Các mục trong side menu — mỗi mục ánh xạ tới một màn hình riêng.
enum MenuItem: String, CaseIterable, Identifiable {
  case home = "Home"
  case profile = "Profile"
  case settings = "Settings"

  var id: Self { self }

  var icon: String {
    switch self {
    case .home:     "house"
    case .profile:  "person"
    case .settings: "gearshape"
    }
  }
}

private struct SideMenuContent: View {
  let selected: MenuItem
  let onSelect: (MenuItem) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Menu")
        .font(.largeTitle.bold())
        .padding(.top, 72)
        .padding(.bottom, 16)

      ForEach(MenuItem.allCases) { item in
        Button {
          onSelect(item)
        } label: {
          HStack(spacing: 16) {
            Image(systemName: item.icon)
              .font(.title3)
              .frame(width: 28)          // icon cùng bề rộng → chữ thẳng cột
            Text(item.rawValue)
              .font(.title3)
              .fontWeight(item == selected ? .bold : .regular)
            Spacer()
          }
          .foregroundStyle(item == selected ? Color.accentColor : Color.primary)
          .frame(height: 48)             // mỗi hàng cùng chiều cao → nhịp đều
          .contentShape(Rectangle())     // bấm được cả hàng, không chỉ chữ
        }
      }
      Spacer()
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .background(Color(.secondarySystemBackground))
    .ignoresSafeArea()
  }
}

// Khung dùng chung (shell): header + push + lớp mờ. Nội dung nhét vào qua @ViewBuilder.
private struct MainContent<Content: View>: View {
  let title: String
  @Binding var isMenuOpen: Bool
  var progress: CGFloat
  let onMenu: () -> Void
  // let onBack: () -> Void
  @ViewBuilder var content: Content

  var body: some View {
    VStack(spacing: 0) {
      // Header tự vẽ (thay cho nav bar)
      HStack(spacing: 18) {
        // Button(action: onBack) { Image(systemName: "chevron.left") }
        Button(action: onMenu) { Image(systemName: "line.3.horizontal") }
        Text(title).font(.headline)   // tiêu đề đổi theo item đang chọn
        Spacer()
      }
      .font(.title3)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

      Divider()

      content                          // màn hình được nhét vào đây
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .id(title)
        .transition(.opacity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
    // Lớp mờ + bắt tap để đóng khi menu mở
    .overlay {
      Color.black.opacity(0.25 * progress)
        .allowsHitTesting(isMenuOpen)
        .onTapGesture(perform: onMenu)
        .ignoresSafeArea()
    }
  }
}

struct SwipeBackEnabler: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    Injector()
  }

  func updateUIViewController(_ vc: UIViewController, context: Context) {}

  private final class Injector: UIViewController, UIGestureRecognizerDelegate {
    private weak var originalDelegate: UIGestureRecognizerDelegate?

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      guard let g = navigationController?.interactivePopGestureRecognizer else { return }
      originalDelegate = g.delegate      // nhớ delegate gốc
      g.isEnabled = true
      g.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      // trả lại nguyên trạng để không ảnh hưởng màn khác
      navigationController?.interactivePopGestureRecognizer?.delegate = originalDelegate
    }

    func gestureRecognizerShouldBegin(_ gr: UIGestureRecognizer) -> Bool {
      (navigationController?.viewControllers.count ?? 0) > 1
    }
  }
}
