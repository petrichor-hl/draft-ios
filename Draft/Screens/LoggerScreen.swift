//
//  LoggerScreen.swift
//  Draft
//
//  `Logger` (os.Logger, iOS 14+, `import OSLog`) — cửa vào Unified Logging của
//  hệ điều hành. Không phải một cái `print` đẹp hơn: `print` ghi ra stdout, chỉ
//  sống trong Xcode console lúc bạn đang cắm máy, và biến mất hoàn toàn ở bản
//  release. `Logger` ghi vào kho log của hệ thống — máy của người dùng thật vẫn
//  giữ lại, và lấy về được qua sysdiagnose hay Console.app.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  1. LOGGER LÀ GÌ
//  ═══════════════════════════════════════════════════════════════════════════
//
//      let log = Logger(subsystem: "com.lam.Draft", category: "checkout")
//      log.notice("Bắt đầu thanh toán")
//
//      subsystem   thường lấy bundle id — "log này của app nào"
//      category    mảng chức năng: "network", "checkout", "camera"…
//
//  Hai nhãn này không phải trang trí: chúng là thứ để LỌC về sau. Có category
//  thì lọc riêng luồng network giữa hàng nghìn dòng; không có thì lại phải đọc
//  bằng mắt như đọc `print`.
//
//  Điểm khác `print` về mặt chi phí: message truyền vào là `OSLogMessage` chứ
//  không phải `String`. Hệ thống lưu dạng nén, hoãn việc format tới lúc AI ĐÓ
//  THẬT SỰ ĐỌC log. Dòng log không ai đọc gần như không tốn gì — nên để lại
//  trong bản release là chuyện bình thường.
//
//  ⚠️ Hệ quả ngược lại: `log.notice("\(chuoiDaGhepSan)")` làm mất lợi thế đó,
//     vì chuỗi đã dựng xong trước khi gọi. Cứ để nội suy nguyên vẹn trong
//     literal.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  2. NĂM MỨC, VÀ MỨC NÀO THÌ CÒN LẠI TRÊN Ổ ĐĨA
//  ═══════════════════════════════════════════════════════════════════════════
//
//      debug    chỉ nằm trong bộ nhớ, KHÔNG lưu — dấu vết lúc đang dev
//      info     trong bộ nhớ; chỉ được lưu khi có người đi thu log
//      notice   MẶC ĐỊNH, lưu xuống đĩa — mốc quan trọng của luồng nghiệp vụ
//      error    lưu — sai nhưng app còn chạy tiếp được
//      fault    lưu — hỏng ở mức không đáng xảy ra, thường là bug của mình
//
//  Cột "có lưu không" mới là cột đáng quan tâm. Bug người dùng gặp lúc 2 giờ
//  sáng, mình không cắm máy vào được: chỉ những gì `notice` trở lên mới còn
//  đó lúc mình đi tìm. Đặt mốc quan trọng ở `debug` là tự xoá bằng chứng.
//
//  Ngược lại, cho mọi thứ vào `error` thì cột error đầy rác và mất luôn tác
//  dụng báo động.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  3. QUYỀN RIÊNG TƯ: MẶC ĐỊNH KHÔNG PHẢI LÀ THỨ BẠN ĐANG THẤY
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Vì log ở lại trên máy người dùng, hệ thống tự che dữ liệu động:
//
//      chuỗi / object động     mặc định PRIVATE → hiện ra là <private>
//      số, bool, scalar        mặc định public
//
//      log.notice("Đăng nhập \(email)")                       // <private>
//      log.notice("Đăng nhập \(email, privacy: .public)")      // hiện thật
//      log.notice("User \(id, privacy: .private(mask: .hash))") // hash ổn định
//
//  `.private(mask: .hash)` là chỗ hay: cùng một user ra cùng một hash, nên vẫn
//  nối được các dòng log của cùng một người mà không lộ danh tính.
//
//  ⚠️ Cái bẫy: khi có debugger cắm vào (tức là lúc chạy từ Xcode) hệ thống
//     KHÔNG che gì cả. Nên mọi thứ trông "vẫn hiện bình thường", và chỉ đến
//     lúc đọc log thật từ máy người dùng mới phát hiện dòng quan trọng nhất
//     là một chữ <private>.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  4. KHI NÀO THÌ DÙNG — VÀ KHI NÀO KHÔNG
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Dùng `Logger` khi câu hỏi là "chuyện gì đã xảy ra trên máy người ta":
//
//    • Vòng đời & luồng nghiệp vụ nhiều bước — đăng nhập, thanh toán, upload:
//      cần biết nó chết ở bước nào.
//          log.notice("Upload xong \(count) ảnh")
//
//    • Lỗi kèm bối cảnh, thay cho `catch { }` im lặng:
//          catch { log.error("Tải hồ sơ hỏng: \(error.localizedDescription)") }
//
//    • Chuyện xảy ra lúc không ai nhìn màn hình: background task, push, thu
//      hồi bộ nhớ, mất mạng.
//
//    • Trạng thái mà QA/người dùng không mô tả lại được, nhưng log thì có.
//
//  Không dùng khi:
//
//    • Chỉ muốn liếc một giá trị trong lúc đang gõ code — `print` hoặc
//      breakpoint nhanh hơn, và không để lại rác.
//
//    • Đo hiệu năng: đó là việc của `OSSignposter` + Instruments, không phải
//      đếm mốc thời gian bằng tay giữa các dòng log.
//
//    • Đếm hành vi người dùng để làm báo cáo: đó là analytics. Log là để chẩn
//      đoán, không phải để thống kê.
//
//    • Đừng log mật khẩu, token, số thẻ — kể cả có `.private`. Thứ tốt nhất
//      là thứ không bao giờ đi vào log.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  5. ĐỌC LOG Ở ĐÂU
//  ═══════════════════════════════════════════════════════════════════════════
//
//      Xcode console      lọc theo subsystem / category ngay khi chạy
//      Console.app (Mac)  xem máy thật đang cắm, kể cả khi không chạy từ Xcode
//      Terminal           log stream --predicate 'subsystem == "com.lam.Draft"'
//      sysdiagnose        gói log người dùng gửi về — chỗ `notice` trở lên
//                         chứng minh giá trị của nó
//      OSLogStore         đọc lại log CỦA CHÍNH APP từ trong app (iOS 15+),
//                         để đính kèm vào form báo lỗi
//

import SwiftUI

struct LoggerScreen: View {
  var body: some View {
    Text("TODO")
      .navigationTitle("Logger")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    LoggerScreen()
  }
}
