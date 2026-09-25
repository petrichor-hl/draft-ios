//
//  AreaChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — AreaMark: LineMark có tô phần dưới đường.
//    .foregroundStyle(LinearGradient)  gradient mờ dần xuống đáy
//    AreaMark(yStart:yEnd:)            dải giữa hai đường (min–max)
//    nhiều AreaMark cùng x             xếp chồng (stacked area)
//    stacking: .unstacked / .center    chồng đè, và streamgraph
//
//  Dữ liệu thứ nhất là giá đóng cửa 24 phiên, vì màn này dựng theo chart
//  của app Chứng khoán — chỗ area chart hay gặp nhất trên iPhone.
//
//  CÂU HỎI, và đây là câu đáng tiền nhất của màn:
//
//    AreaMark tô từ đường giá XUỐNG ĐƯỜNG GỐC. Mà mark số thì luôn kéo
//    miền về chứa 0 (đã đo ở màn Range). Với giá cổ phiếu 259–340, để 0
//    trong miền là ép toàn bộ biến động thành một vệt phẳng sát đỉnh.
//
//    Vậy khi chartYScale cắt 0 ra khỏi miền thì vùng tô đi đâu? Tô kín
//    xuống đáy khung, hay bị clip mất vì đường gốc không còn nằm trong
//    miền nữa? App Chứng khoán tô kín, nhưng không rõ nó được Charts cho
//    không hay phải tự dựng bằng AreaMark(yStart:yEnd:).
//
//  ĐÃ ĐO trên simulator.
//
//  TÔ KÍN XUỐNG ĐÁY. Cắt 0 khỏi miền không làm mất phần tô: chart B vẫn
//  đầy màu từ đường giá xuống hết khung. AreaMark không đòi đường gốc
//  phải nằm trong miền. Vậy chart app Chứng khoán dựng được bằng AreaMark
//  thường cộng chartYScale, không cần tới AreaMark(yStart:yEnd:).
//
//  NHƯNG VÙNG TÔ TRÀN QUA DẢI NHÃN TRỤC X VÀ ĐÈ LÊN NHÃN. Chart B mất
//  sạch nhãn ngày, trong khi chart A cùng dữ liệu vẫn còn đủ. Nhãn không
//  biến mất — chart C chứng minh: cùng miền 250–350, nhưng gradient nhạt
//  dần về đáy nên nhãn hiện xuyên qua lớp tô.
//
//  Đây mới là lý do thật của cái gradient trong app Chứng khoán. Không
//  phải để đẹp: tô đặc thì mất trục.
//
//  CHỮA ĐƯỢC, hai cách, chart H và I đều giữ màu đặc mà nhãn vẫn đọc:
//
//    H  .chartPlotStyle { $0.clipped() } — closure này đưa cho ta VÙNG VẼ
//       dưới dạng một View bình thường, nên .clipped() trên nó cắt mọi
//       thứ thò ra ngoài. Một dòng, không đụng tới mark.
//
//    I  AreaMark(x:yStart:yEnd:) với yStart là cận dưới của miền. Không
//       cắt gọt gì, mà chặn từ gốc: vùng tô không còn đi tìm đường gốc
//       nên không bao giờ xuống quá đáy khung.
//
//  H ngắn hơn. I không dựa vào hành vi clip nào, và là cách DUY NHẤT nếu
//  muốn đáy nằm ở một mức khác — ví dụ tô từ giá tham chiếu lên, phần
//  trên xanh phần dưới đỏ.
//
//  Cả hai đều giới hạn ở chuyện tô. Muốn nhãn trục hẳn hoi thì vẫn nên
//  để gradient tắt dần như chart C và như app Chứng khoán: lúc đó nhãn
//  nằm TRONG vùng tô mà vẫn đọc được, đỡ tốn một dải trống dưới chart.
//
//  Và đừng nhét Chart vào closure của chartPlotStyle: closure chạy trong
//  layout pass, tạo Chart mới bên trong là đệ quy vô hạn rồi tràn stack.
//  Màn Toolbox/Garmin đã dính một lần.
//
//  KHÔNG CÓ KIỂU "AREA CÓ VIỀN". Phải vẽ hai mark trên cùng bộ dữ liệu,
//  AreaMark tô rồi LineMark đặt nét lên trên.
//
//  PHẦN STACKED — dữ liệu thứ hai, lượt truy cập theo tuần chia theo ba
//  nguồn. Giá cổ phiếu chỉ có một chuỗi nên không chồng được.
//
//  Ba section E, F, G đi qua ba giá trị của tham số stacking:, cùng một
//  bộ dữ liệu, chỉ đổi đúng một chữ. Xem cùng con số kể ba câu chuyện
//  khác nhau thế nào.
//
//  THỨ TỰ CHỒNG CŨNG LẤY TỪ MẢNG, y như BarMark ở màn Column. Đo bằng
//  cách tạm trỏ chart E vào một mảng xoay thứ tự ba nguồn mỗi tuần một
//  nấc, rồi xoá đi sau khi chụp.
//
//  Với cột thì hậu quả là màu nhảy giữa các cột, khó đọc nhưng từng cột
//  vẫn đúng. Với area thì thành thảm hoạ: mỗi dải là một đường liền nối
//  các điểm CỦA CHÍNH NÓ, mà vị trí chồng của nó lại nhảy lên nhảy xuống
//  giữa các tuần, nên ba dải luồn xuyên qua nhau thành một mớ răng cưa.
//  Đường viền trên cùng cũng hết là tổng: nó chỉ đúng tại các điểm dữ
//  liệu, còn giữa hai điểm thì nối bừa.
//
//  Nên với stacked area, sắp mảng nguồn không phải chuyện thẩm mỹ mà là
//  điều kiện để chart có nghĩa.
//
//  CÒN LẠI của màn này: bản clone hẳn chart AAPL với nền tối, trục bên
//  phải, volume chart ở dưới.
//

import Charts
import SwiftUI

private let firstDay = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1))!

private struct DailyPrice: Identifiable {
  let id = UUID()
  let day: Date
  let close: Double
  let low: Double
  let high: Double
}

/// Hai tư phiên, xu hướng đi lên nhưng có mấy nhịp lún — cho giống biểu đồ
/// thật, đừng trơn quá. Biên độ trong phiên tính theo chỉ số nên vừa đều
/// đặn vừa không lặp lại.
private let prices: [DailyPrice] = {
  let calendar = Calendar.current
  let closes: [Double] = [
    268, 272, 265, 259, 263, 271, 278, 275,
    283, 291, 288, 296, 305, 299, 293, 302,
    314, 322, 317, 311, 325, 334, 330, 340,
  ]
  
  return closes.enumerated().map { index, close in
    let spread = 3 + Double((index * 7) % 9)
    return DailyPrice(
      day: calendar.date(byAdding: .day, value: index, to: firstDay)!,
      close: close,
      low: close - spread * 0.6,
      high: close + spread * 0.4
    )
  }
}()

private struct Visit: Identifiable {
  let id = UUID()
  let week: Date
  let source: String
  let count: Int
}

/// Miền dùng cho chart B trở đi. Cận dưới 250 nằm dưới giá thấp nhất,
/// nên 0 bị cắt khỏi miền — chính là tình huống sinh ra chuyện vùng tô
/// tràn qua nhãn trục.
private let priceRange: ClosedRange<Double> = 250...350

private let sourceOrder = ["Tìm kiếm", "Mạng xã hội", "Trực tiếp"]

/// Mười hai tuần, ba nguồn truy cập. Tìm kiếm lên đều, Trực tiếp gần như
/// phẳng, còn Mạng xã hội có một cú nhảy vọt giữa kỳ rồi tụt lại — kiểu
/// một bài viral. Đúng dạng dữ liệu mà stacked area sinh ra để kể.
private let visits: [Visit] = {
  let calendar = Calendar.current
  let weekly: [(Int, Int, Int)] = [
    (1_200, 300, 500), (1_250, 340, 510), (1_180, 420, 495), (1_300, 560, 520),
    (1_350, 880, 530), (1_320, 1_240, 515), (1_400, 1_100, 540), (1_460, 760, 555),
    (1_510, 540, 560), (1_490, 460, 575), (1_560, 430, 590), (1_620, 410, 600),
  ]
  
  return weekly.enumerated().flatMap { index, row -> [Visit] in
    let week = calendar.date(byAdding: .weekOfYear, value: index, to: firstDay)!
    return zip(sourceOrder, [row.0, row.1, row.2]).map { source, count in
      Visit(week: week, source: source, count: count)
    }
  }
}()

struct AreaChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .frame(height: 220)
      } header: {
        Text("A — AreaMark(x:y:) trần")
      } footer: {
        Text("Giống hệt LineMark, chỉ thêm phần tô từ đường giá xuống ĐƯỜNG GỐC. Mà đường gốc là 0, nên miền trục Y bị kéo về 0 và cả dải giá 259–340 bẹp thành một vệt sát đỉnh. Biến động 30% trong hai tư phiên nhìn như đường thẳng.")
      }
      
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: priceRange)
        .frame(height: 220)
      } header: {
        Text("B — chartYScale cắt 0 ra khỏi miền")
      } footer: {
        Text("Miền 250–350, biến động hiện ra đầy đủ, và phần tô vẫn kín xuống đáy — AreaMark không đòi đường gốc phải nằm trong miền. Nhưng so với chart A thì nhãn ngày ở trục X đâu mất rồi? Vùng tô tràn qua cả dải nhãn và đè lên. Chart C chứng minh nhãn vẫn còn nguyên ở đó, còn H và I là hai cách chữa hẳn.")
      }
      
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(
            .linearGradient(
              colors: [.green.opacity(0.45), .green.opacity(0.02)],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          
          LineMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: priceRange)
        .chartYAxis {
          AxisMarks(position: .trailing)
        }
        .frame(height: 220)
      } header: {
        Text("C — gradient, và LineMark vẽ đè lên")
      } footer: {
        Text("Nhãn ngày hiện lại rồi — cùng miền như chart B, chỉ khác lớp tô nhạt dần nên nhìn xuyên qua được. Đó mới là lý do thật của cái gradient trong app Chứng khoán: tô đặc thì mất trục. Và Swift Charts không có kiểu \"area có viền\", phải vẽ HAI mark: AreaMark tô gradient rồi LineMark đặt nét sắc lên trên. Gradient ở đây an toàn vì chỉ một chuỗi — thêm chuỗi thứ hai là dính đúng bẫy bounding box ở Basics #4.")
      }
      
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            yStart: .value("Thấp nhất", item.low),
            yEnd: .value("Cao nhất", item.high)
          )
          .foregroundStyle(.green.opacity(0.25))
          
          LineMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: priceRange)
        .chartYAxis {
          AxisMarks(position: .trailing)
        }
        .frame(height: 220)
      } header: {
        Text("D — AreaMark(x:yStart:yEnd:) dải thấp–cao")
      } footer: {
        Text("Hai đầu thay vì một, y như BarMark ở màn Range — nhưng liền mạch chứ không đứt thành từng thanh. Dải mờ là biên độ trong phiên, đường đậm là giá đóng cửa. Dùng khi x liên tục và ta muốn thấy cả mức lẫn độ không chắc chắn: khoảng tin cậy, dự báo, nhiệt độ ngày.")
      }
      Section {
        Chart(visits) { item in
          AreaMark(
            x: .value("Tuần", item.week),
            y: .value("Lượt", item.count)
          )
          .foregroundStyle(by: .value("Nguồn", item.source))
        }
        .chartForegroundStyleScale(domain: sourceOrder)
        .frame(height: 220)
      } header: {
        Text("E — nhiều chuỗi cùng x → stacked area")
      } footer: {
        Text("Chồng là mặc định, y như BarMark ở màn Column — không cần tham số gì. Đường viền trên cùng là TỔNG lượt truy cập, mỗi dải là phần đóng góp của một nguồn. Nhưng chỉ dải dưới cùng có đáy phẳng để dóng; hai dải trên bị đáy nhấp nhô của dải dưới đẩy lên đẩy xuống, nên nhìn thì thấy xu hướng chứ đo thì không đo được. Và mảng nguồn BẮT BUỘC phải sắp nhất quán: thứ tự chồng lấy từ thứ tự hàng trong mảng, xáo lên là ba dải luồn xuyên qua nhau thành răng cưa.")
      }
      
      Section {
        Chart(visits) { item in
          AreaMark(
            x: .value("Tuần", item.week),
            y: .value("Lượt", item.count),
            stacking: .unstacked
          )
          .foregroundStyle(by: .value("Nguồn", item.source))
          .opacity(0.45)
        }
        .chartForegroundStyleScale(domain: sourceOrder)
        .frame(height: 220)
      } header: {
        Text("F — stacking: .unstacked")
      } footer: {
        Text("Ba vùng cùng mọc từ đáy 0 và đè lên nhau, phải hạ opacity mới nhìn xuyên được. Đổi lại mỗi chuỗi có đáy phẳng riêng nên so sánh trực tiếp được: thấy rõ tuần thứ sáu Mạng xã hội gần đuổi kịp Tìm kiếm. Cái mất là TỔNG — không còn đường viền nào cho biết cộng lại bao nhiêu.")
      }
      
      Section {
        Chart(visits) { item in
          AreaMark(
            x: .value("Tuần", item.week),
            y: .value("Lượt", item.count),
            stacking: .center
          )
          .foregroundStyle(by: .value("Nguồn", item.source))
        }
        .chartForegroundStyleScale(domain: sourceOrder)
        .chartYAxis(.hidden)
        .frame(height: 220)
      } header: {
        Text("G — stacking: .center, tức streamgraph")
      } footer: {
        Text("Vẫn chồng, nhưng đối xứng quanh trục giữa thay vì mọc từ đáy. Không dải nào bị đường gốc ghìm nên hình dáng từng dải đọc dễ hơn hẳn chart E — cú phình của Mạng xã hội hiện thành một cái bụng rõ rệt. Cái giá phải trả: trục Y mất hết ý nghĩa nên ẩn luôn, chart này chỉ để cảm nhận nhịp chứ không để đọc số.")
      }
      
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: priceRange)
        .chartPlotStyle { plotArea in
          plotArea.clipped()
        }
        .frame(height: 220)
      } header: {
        Text("H — chữa cách 1: chartPlotStyle { $0.clipped() }")
      } footer: {
        Text("Y hệt chart B, màu vẫn đặc, thêm đúng một modifier. chartPlotStyle đưa cho ta VÙNG VẼ như một View bình thường, nên .clipped() trên nó cắt mọi thứ thò ra ngoài. Lưu ý: chỉ được trang trí vùng vẽ trong closure này — nhét một Chart vào đó là đệ quy layout rồi tràn stack, màn Toolbox/Garmin đã dính.")
      }
      
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            yStart: .value("Đáy", priceRange.lowerBound),
            yEnd: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: priceRange)
        .frame(height: 220)
      } header: {
        Text("I — chữa cách 2: nói thẳng đáy của vùng tô")
      } footer: {
        Text("Không cắt gọt gì cả, mà sửa từ gốc: thay vì để AreaMark tự tìm đường gốc rồi tô xuống tận đó, ta nói luôn yStart là cận dưới của miền, nên vùng tô không bao giờ đi xa hơn đáy khung. Dài hơn cách H một chút nhưng không dựa vào hành vi clip nào — và là cách duy nhất nếu muốn đáy nằm ở mức khác, ví dụ tô từ giá tham chiếu lên.")
      }
    }
    .navigationTitle("Area")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AreaChartScreen()
  }
}
