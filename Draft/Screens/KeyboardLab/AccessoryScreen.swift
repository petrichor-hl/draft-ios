//
//  AccessoryScreen.swift
//  Draft
//
//  Hướng inputAccessoryView (bar = phụ kiện bàn phím) + flipped list.
//  Bước hiện tại: render danh sách tin (UICollectionViewController flipped + sampleMessages).
//  inputAccessoryView -> làm ở bước sau.
//

import SwiftUI
import UIKit

struct AccessoryScreen: View {
  var body: some View {
    ChatController()
      .ignoresSafeArea(.all, edges: .bottom)
      .navigationTitle("Accessory")
      .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Cầu nối SwiftUI -> UIViewController
private struct ChatController: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> ChatViewController {
    ChatViewController()
  }
  func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {}
}

// MARK: - VC: UICollectionViewController flipped (list layout)
private final class ChatViewController: UICollectionViewController {

  private lazy var barView = InputBarView()

  // ⭐ Collection view BẮT BUỘC có layout ở init.
  init() {
    // list layout: trông như table, cell TỰ CO theo nội dung, tắt separator.
    var config = UICollectionLayoutListConfiguration(appearance: .plain)
    config.showsSeparators = false
    let layout = UICollectionViewCompositionalLayout.list(using: config)
    super.init(collectionViewLayout: layout)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // collectionView đã có sẵn (nó CHÍNH LÀ view); dataSource/delegate = self tự động.
    collectionView.backgroundColor = .systemBackground
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.allowsSelection = false
    collectionView.keyboardDismissMode = .interactiveWithAccessory
    // flip: item 0 rơi xuống đáy -> tin mới nhất neo ở đáy
    collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    collectionView.addGestureRecognizer(tap)
  }

  // MARK: - Data source
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    sampleMessages.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    // item 0 = tin MỚI NHẤT = phần tử CUỐI mảng (sampleMessages xếp cũ -> mới)
    let message = sampleMessages[sampleMessages.count - 1 - indexPath.item]
    cell.contentConfiguration = UIHostingConfiguration {
      MessageRow(message: message)
    }
    return cell
  }

  override var inputAccessoryView: UIView? {
    barView
  }

  override var canBecomeFirstResponder: Bool { true }

  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    becomeFirstResponder()
  }

  @objc private func dismissKeyboard() {
    print("tap fired")
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil, from: nil, for: nil
    )
  }
}

// MARK: - Bong bóng tin nhắn (SwiftUI)
private struct MessageRow: View {
  let message: ChatMessage
  var body: some View {
    HStack {
      if message.isMine { Spacer(minLength: 48) }
      Text(message.text)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
          (message.isMine ? Color.blue : Color.gray.s500).opacity(0.15),
          in: .rect(cornerRadius: 16)
        )
      if !message.isMine { Spacer(minLength: 48) }
    }
    // ⭐ Lật NỘI DUNG lại (SwiftUI render effect — miễn nhiễm với layout attributes)
    .scaleEffect(x: 1, y: -1)
  }
}

private final class InputBarView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    autoresizingMask = .flexibleHeight   // cho hệ thống định cỡ chiều cao accessory
    backgroundColor = .secondarySystemBackground

    let textField = UITextField()
    textField.placeholder = "Aa"
    textField.borderStyle = .roundedRect

    let send = UIButton(type: .system)
    send.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)

    let stack = UIStackView(arrangedSubviews: [textField, send])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      // đáy nội dung né home indicator (bar nền vẫn fill xuống đáy)
      stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // .zero + flexibleHeight -> accessory tự co theo autolayout bên trong
  override var intrinsicContentSize: CGSize { .zero }
}
