//
//  KeyboardLayoutGuideScreen.swift
//  Draft
//
//  Cách A' — keyboardLayoutGuide: thanh nhập là subview thường, ghim đáy vào
//  "đường ray bàn phím". Đường ray bám khung bàn phím theo thời gian thực
//  (kể cả kéo interactive) và tự nằm ở đáy khi không có phím -> bar dừng êm.
//  List: UITableView LẬT NGƯỢC (transform scaleY -1) + cell lật lại -> tin mới
//  nhất neo TỰ NHIÊN ở đáy, KHÔNG cần code giữ contentOffset khi phím hiện/ẩn.
//

import SwiftUI
import UIKit

struct KeyboardLayoutGuideScreen: View {
  var body: some View {
    ChatController()
    // bỏ safe area đáy (.all = .container + .keyboard): view tràn xuống đáy vật lý (để bar fill)
    // + SwiftUI không tự né phím (nhường keyboardLayoutGuide)
      .ignoresSafeArea(.all, edges: .bottom)
      .navigationTitle("Layout Guide")
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

// MARK: - VC: bar ghim vào keyboardLayoutGuide + list UIKit (flipped)
private final class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  private let barView = InputBarView()
  private let tableView = UITableView()
  private var messages = sampleMessages   // dữ liệu MUTABLE để append tin mới
  
  // MARK: - Freeze scroll khi interactive-dismiss
  private var keyboardShownTop: CGFloat?   // kbTop lúc phím hiện đủ (mốc so sánh)
  private var frozenOffset: CGPoint?       // offset bị khoá trong lúc dismiss
  private var lastOffset: CGPoint = .zero  // offset "tốt" của khung trước
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    // ⚠️ KNOWN: flipped table + .interactive chưa hoàn hảo — kéo interactive vừa
    //    CUỘN vừa dismiss (đo được offset.y tăng khi kéo). Chuẩn iMessage/Zalo cần
    //    inputAccessoryView (xem MessageKit/InputBarAccessoryView).
    tableView.keyboardDismissMode = .interactive   // kéo để ẩn phím
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    // ⭐ LẬT NGƯỢC table: row 0 rơi xuống đáy -> tin mới nhất neo tự nhiên ở đáy,
    //    khi phím co table từ dưới lên, row 0 tự đi theo -> hết cần chỉnh offset.
    tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    barView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    view.addSubview(barView)
    
    barView.onSend = { [weak self] text in
      self?.addMessage(text)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    tableView.addGestureRecognizer(tap)
    
    // Mốc để phát hiện interactive-dismiss (kbTop tụt so với lúc phím hiện đủ)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidHide),
      name: UIResponder.keyboardDidHideNotification,
      object: nil
    )
    
    view.keyboardLayoutGuide.usesBottomSafeArea = true
    // Defaults to 0.0. When a user scrolls to dismiss the keyboard (see @c UIScrollViewKeyboardDismissMode),
    // the gesture waits to start the dismiss until it intersects with the keyboard.
    // This adds padding above the keyboard to start the dismiss earlier. Negative values will be treated as 0.
    // ⬇️
    // view.keyboardLayoutGuide.keyboardDismissPadding = 40
    
    NSLayoutConstraint.activate([
      // Bar: rộng full, ĐÁY ghim vào ĐỈNH đường ray bàn phím
      barView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      barView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      barView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // List: từ trên (dưới nav bar) xuống tới ĐỈNH bar
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: barView.topAnchor),
    ])
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // ⭐ iOS 17.0:
    //    Dời ngưỡng interactive-dismiss LÊN mép trên InputBar (iOS 17+).
    //    padding = khoảng từ ĐỈNH PHÍM tới MÉP TRÊN bar = phần bar hiển thị trên phím.
    //    (bar bám keyboardLayoutGuide nên giá trị này ổn định ở cả 2 trạng thái phím.)
    let barTopAboveKeyboard = view.keyboardLayoutGuide.layoutFrame.minY - barView.frame.minY
    // print("barTopAboveKeyboard = \(barTopAboveKeyboard)")
    tableView.keyboardLayoutGuide.keyboardDismissPadding = barTopAboveKeyboard
  }
  
  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    // Lật cell lại (scaleY -1) để bù cho table đang bị lật -> chữ xuôi
    cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    cell.backgroundColor = .clear
    // row 0 ở đáy -> map về tin MỚI NHẤT = phần tử CUỐI mảng (messages xếp cũ -> mới)
    let message = messages[messages.count - 1 - indexPath.row]
    cell.contentConfiguration = UIHostingConfiguration {
      MessageRow(message: message)
    }
    return cell
  }
  
  // MARK: - Gửi tin
  private func addMessage(_ text: String) {
    messages.append(ChatMessage(text: text, isMine: true))
    // flipped: tin mới nhất = row 0 (đáy màn hình)
    let top = IndexPath(row: 0, section: 0)
    tableView.insertRows(at: [top], with: .fade)
    // .top (hệ CHƯA lật) = đáy (hệ ĐÃ lật) -> cuộn về tin mới nhất
    tableView.scrollToRow(at: top, at: .top, animated: true)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @objc private func keyboardDidShow() {
    keyboardShownTop = view.keyboardLayoutGuide.layoutFrame.minY
  }
  
  @objc private func keyboardDidHide() {
    keyboardShownTop = nil
    frozenOffset = nil
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Không có mốc => phím đang ẩn => cuộn bình thường, chỉ ghi nhớ offset tốt
    guard let shownTop = keyboardShownTop else {
      lastOffset = scrollView.contentOffset
      return
    }
    let kbTop = view.keyboardLayoutGuide.layoutFrame.minY
    let dismissing = kbTop > shownTop      // đỉnh phím đã tụt => đang interactive-dismiss
    
    if dismissing && scrollView.isTracking {
      if frozenOffset == nil { frozenOffset = lastOffset }   // khoá tại offset NGAY TRƯỚC khi engage
      scrollView.contentOffset = frozenOffset!               // ép về => triệt phần cuộn thừa
    } else {
      frozenOffset = nil
      lastOffset = scrollView.contentOffset                  // cuộn thường: liên tục cập nhật mốc
    }
  }
}

// MARK: - Bong bóng tin nhắn (SwiftUI) — nội dung cell
private struct MessageRow: View {
  let message: ChatMessage
  var body: some View {
    HStack {
      if message.isMine { Spacer(minLength: 48) }
      Text(message.text)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
          (message.isMine ? Color.blue : Color.gray).opacity(0.15),
          in: .rect(cornerRadius: 16)
        )
      if !message.isMine { Spacer(minLength: 48) }
    }
  }
}

// MARK: - Thanh nhập (UIKit) — UITextView đa dòng, tự cao dần tới 4 dòng
private final class InputBarView: UIView, UITextViewDelegate {
  private let textView = UITextView()
  private let placeholderLabel = UILabel()
  private var heightConstraint: NSLayoutConstraint!
  private let maxLines = 4
  
  var onSend: ((String) -> Void)?   // callback: bấm nút send -> báo text ra ngoài
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .secondarySystemBackground
    
    // UITextView đa dòng — return = XUỐNG DÒNG (mặc định), không gửi.
    textView.font = .preferredFont(forTextStyle: .body)
    textView.isScrollEnabled = false           // false -> tự giãn theo nội dung
    textView.backgroundColor = .systemBackground
    textView.layer.cornerRadius = 18
    textView.textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 10)
    textView.textContainer.lineFragmentPadding = 0
    textView.delegate = self
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    // Placeholder (UITextView không có sẵn) — hiện khi rỗng
    placeholderLabel.text = "Aa"
    placeholderLabel.font = textView.font
    placeholderLabel.textColor = .placeholderText
    placeholderLabel.isUserInteractionEnabled = false
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    textView.addSubview(placeholderLabel)
    
    let send = UIButton(type: .system)
    send.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
    send.setContentHuggingPriority(.required, for: .horizontal)
    send.setContentCompressionResistancePriority(.required, for: .horizontal)
    send.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    
    let stack = UIStackView(arrangedSubviews: [textView, send])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .bottom                  // nút send neo ĐÁY khi ô cao dần
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)
    
    heightConstraint = textView.heightAnchor.constraint(equalToConstant: minHeight)
    
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      stack.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -8),
      
      heightConstraint,
      
      placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 10),
      placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 9),
    ])
  }
  
  // Chiều cao 1 dòng / tối đa maxLines dòng (gồm inset trên+dưới)
  private var lineHeight: CGFloat { textView.font?.lineHeight ?? 20 }
  private var verticalInset: CGFloat { textView.textContainerInset.top + textView.textContainerInset.bottom }
  private var minHeight: CGFloat { ceil(lineHeight + verticalInset) }
  private var maxHeight: CGFloat { ceil(lineHeight * CGFloat(maxLines) + verticalInset) }
  
  func textViewDidChange(_ tv: UITextView) {
    placeholderLabel.isHidden = !tv.text.isEmpty
    // đo chiều cao cần để chứa hết text ở bề rộng hiện tại
    let fitting = tv.sizeThatFits(CGSize(width: tv.bounds.width, height: .greatestFiniteMagnitude)).height
    heightConstraint.constant = min(max(fitting, minHeight), maxHeight)
    tv.isScrollEnabled = fitting > maxHeight    // quá 4 dòng -> cho scroll trong ô
  }
  
  @objc private func sendTapped() {
    let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    onSend?(text)
    textView.text = ""
    textViewDidChange(textView)                 // reset chiều cao + hiện placeholder
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
