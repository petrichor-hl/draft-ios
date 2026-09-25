//
//  StocksScreen.swift
//  Draft
//
//  ĐỀ BÀI — dựng lại chart giá cổ phiếu trong app Chứng khoán của iPhone,
//  tab 1Y. Đó là area chart: LineMark nét sắc đặt trên AreaMark tô
//  gradient, trục Y bên phải, miền khít dữ liệu.
//
//  Khác Garmin ở chỗ Garmin phải đổi màu theo giá trị nên buộc dùng
//  Canvas. Chart này một màu duy nhất, nên AreaMark thường là đủ — màn
//  Types #6 đã đo: cắt 0 khỏi miền không làm mất phần tô.
//
//    1  bản clone
//    2  nền tối: environment cộng listRowBackground
//
//  Hai chart dùng CHUNG một View đã tách ra, chỉ khác cái bọc ngoài.
//
//  Trước đây còn hai chart nữa đứng trước: một LineMark trần, và một bản
//  chưa neo đáy vùng tô. Đã xoá sau khi rút được kết luận bên dưới.
//
//  ĐÃ ĐO trên simulator.
//
//  PHẦN LỚN "DÁNG STOCKS" NẰM Ở MIỀN, không ở màu. Đo bằng cách đặt cạnh
//  nhau một chart để mặc Charts tự quyết và một chart chỉ khác ở chỗ đặt
//  chartYScale: cái đầu có 0 trong miền nên cả năm biến động co vào một
//  phần ba trên của khung, trông như đường gần phẳng; cái sau lấy đúng
//  min…max nên trải hết chiều cao và mọi nhịp lên xuống hiện ra. Gradient
//  chỉ là lớp sơn thêm vào sau. Hai chart đó đã xoá.
//
//  environment(colorScheme) CHỈ ĐỔI CÁCH MÀU NGỮ NGHĨA TỰ TÍNH, KHÔNG VẼ
//  NỀN CHO AI. Đo bằng một chart chỉ thêm mỗi dòng đó vào thẻ trắng:
//  nhãn trục và đường kẻ lưới nhạt tới mức gần đọc không ra, vì chúng
//  chuyển sang tông sáng để nổi trên một nền tối không hề tồn tại. Chart
//  đó đã xoá sau khi có kết luận; chart 4 là bản đủ cả hai thứ.
//
//  Màu cứng thì không nghe lệnh environment: đường .green không đổi.
//  Đúng ra .green là màu hệ thống nên vẫn có biến thể riêng cho chế độ
//  tối, chỉ là hai biến thể gần nhau tới mức mắt không phân biệt nổi.
//
//  Chart 2 và 3 giữ nền sáng vì màn này nằm trong List sáng; chart 4 để
//  đó làm bản tham khảo khi cần dựng đúng bản thật.
//
//  PHẢI NEO ĐÁY VÙNG TÔ, và neo bằng yStart:yEnd: chứ không phải bằng
//  clipped(). Để AreaMark tự tìm đường gốc thì hộp bao của nó thò xuống
//  tận 0: vùng tô phủ qua dải nhãn ngày, và gradient — vốn resolve theo
//  hộp bao — có nấc nhạt rơi ra ngoài khung, trong khung chỉ còn phần
//  đậm nên tô ra gần như một màu đều.
//
//  Types #6 đo được hai cách chặn. clipped() ngắn hơn nhưng chỉ CẮT HÌNH,
//  không sửa hộp bao, nên nó cắt đi đúng cái phần đã nhạt và gradient vẫn
//  sai. yStart:yEnd: kéo hộp bao về trùng vùng vẽ nên chữa cả hai chuyện
//  một lượt. Màu đặc thì hai cách như nhau; có gradient thì chỉ cách sau
//  đúng.
//
//  DỮ LIỆU PHẢI TẤT ĐỊNH. Dùng Double.random trong mảng let thì mỗi lần
//  mở app chart lại khác, không đối chiếu với ảnh chụp được. Ở đây tự
//  viết một LCG với hằng số của Knuth, seed cố định.
//
//  CÒN LẠI: nhãn trục X hiện đang là "thg 11 2025" do Charts tự chọn,
//  bản thật chỉ ghi tên tháng và chỉ ghi năm ở chỗ giao năm — cần
//  AxisValueLabel dựng bằng ViewBuilder, đúng gạch còn nợ ở Basics #5.
//  Và volume chart bằng BarMark ở dưới, dùng chung trục thời gian.
//

import Charts
import SwiftUI

struct StockBar: Identifiable {
  let id = UUID()
  let day: Date
  let close: Double
  let volume: Double
}

/// Một năm giá đóng cửa, sinh bằng công thức tất định để mỗi lần mở app
/// đều ra đúng một hình — dùng Double.random thì chart nhảy mỗi lần chạy,
/// không đối chiếu được.
///
/// Nền là một đường đi lên, cộng hai sóng sin lệch chu kỳ cho có nhịp lên
/// xuống, cộng nhiễu từng phiên để có cái răng cưa đặc trưng của chart
/// tài chính. Nhiễu lấy từ một LCG tự viết, hằng số quen thuộc của Knuth.
private let bars: [StockBar] = {
  let calendar = Calendar.current
  let start = calendar.date(from: DateComponents(year: 2025, month: 9, day: 25))!
  let count = 252          // số phiên giao dịch của một năm

  var seed: UInt64 = 20_260_925
  func nextUnit() -> Double {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Double(seed >> 33) / Double(1 << 31)
  }

  return (0..<count).map { index in
    let progress = Double(index) / Double(count - 1)
    let trend = 252 + 84 * progress
    let wave = 13 * sin(Double(index) / 27) + 7 * sin(Double(index) / 9.5)
    let noise = (nextUnit() - 0.5) * 6

    return StockBar(
      day: calendar.date(byAdding: .day, value: index, to: start)!,
      close: trend + wave + noise,
      volume: 38 + nextUnit() * 34 + abs(wave) * 0.9
    )
  }
}()

/// Khít đúng dữ liệu, không nới thêm — app Chứng khoán cũng vậy, nhãn
/// trên cùng chính là đỉnh của kỳ.
private let priceDomain: ClosedRange<Double> = {
  let closes = bars.map(\.close)
  return closes.min()!...closes.max()!
}()

struct StocksScreen: View {

  /// Thân chart 2, tách riêng để chart 3 và 4 dùng lại y nguyên. Cùng một
  /// View, chỉ khác cái environment bọc ngoài — có vậy mới quy được mọi
  /// khác biệt trên màn hình về đúng một nguyên nhân.
  private var priceChart: some View {
    Chart(bars) { bar in
      AreaMark(
        x: .value("Ngày", bar.day),
        yStart: .value("Đáy", priceDomain.lowerBound),
        yEnd: .value("Giá", bar.close)
      )
      .foregroundStyle(
        .linearGradient(
          colors: [.green.opacity(0.35), .green.opacity(0.01)],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      LineMark(
        x: .value("Ngày", bar.day),
        y: .value("Giá", bar.close)
      )
      .foregroundStyle(.green)
      .lineStyle(StrokeStyle(lineWidth: 1.5))
    }
    .chartYScale(domain: priceDomain)
    .chartYAxis {
      AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) {
        AxisGridLine()
        AxisValueLabel()
      }
    }
  }

  var body: some View {
    List {
      Section {
        priceChart
          .frame(height: 240)
      } header: {
        Text("1 — bản clone")
      } footer: {
        Text("chartYScale lấy đúng min…max nên đường giá trải hết chiều cao — một mình nó làm nên phần lớn cái dáng Stocks. Trục sang phải, bốn mốc. AreaMark tô gradient rồi LineMark đè lên lấy nét sắc, vì Swift Charts không có kiểu area có viền. Và AreaMark dùng dạng yStart:yEnd: neo đáy vào cận dưới của miền: để nó tự tìm đường gốc thì hộp bao thò xuống tận 0, vùng tô phủ qua dải nhãn ngày, mà gradient lại resolve theo hộp bao nên nấc nhạt rơi ra ngoài khung và trong khung chỉ còn phần đậm. Types #6 chart C và D đo kỹ hai cách chặn.")
      }

      Section {
        priceChart
          .frame(height: 200)
          .environment(\.colorScheme, .dark)
      } header: {
        Text("2 — nền tối: environment cộng listRowBackground")
      } footer: {
        Text("Bản thật nền đen, đây là cách dựng: listRowBackground cho cái thẻ, cộng environment(colorScheme, .dark) cho Chart. Hai thứ phải đi cùng nhau — environment chỉ đổi cách các màu ngữ nghĩa TỰ TÍNH, nó không tự vẽ nền cho ai, bỏ listRowBackground đi là nhãn trục nhạt tới mức gần đọc không ra trên thẻ trắng. Đổi lại, không phải chỉ định foregroundStyle cho từng AxisValueLabel, từng AxisGridLine.")
      }
      .listRowBackground(Color(white: 0.11))
    }
    .navigationTitle("Stocks — Giá cổ phiếu")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    StocksScreen()
  }
}
