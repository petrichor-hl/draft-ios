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
//  DỰNG TỪNG LỚP, mỗi chart thêm một thứ, để thấy cái nào đóng góp gì:
//
//    1  LineMark trần, không modifier nào — bản Charts tự quyết
//    2  đủ bộ: miền khít, trục phải, gradient, line đè lên
//    3  AreaMark(yStart:yEnd:) neo đáy vào cận dưới của miền — vùng tô
//       thôi tràn xuống dải nhãn, và gradient mới trải đúng
//    4  nền tối: environment cộng listRowBackground
//
//  Cả bốn dùng CHUNG một View đã tách ra, chỉ khác cái bọc ngoài. Có vậy
//  mới quy được mọi khác biệt trên màn hình về đúng một nguyên nhân.
//
//  ĐÃ ĐO trên simulator.
//
//  PHẦN LỚN "DÁNG STOCKS" NẰM Ở MIỀN, không ở màu. Chart 1 và chart 2 là
//  cùng một bộ số: chart 1 có 0 trong miền nên cả năm biến động co vào
//  một phần ba trên của khung, trông như đường gần phẳng; chart 2 lấy
//  đúng min…max nên nó trải hết chiều cao và mọi nhịp lên xuống hiện ra.
//  Gradient chỉ là lớp sơn thêm vào sau.
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
//  NHÃN TRỤC X Ở CHART 2 NHÌN XUYÊN QUA ĐƯỢC vì gradient tắt gần hẳn ở
//  đáy (opacity 0.01). Đúng cơ chế đã đo ở Types #6: vùng tô tràn qua
//  dải nhãn và đè lên nó, tô đặc là mất trục.
//
//  Chart 3 chặn hẳn, và đó mới là bố cục của bản thật: nhãn tháng nằm
//  dưới vùng vẽ, không dính màu. Nhìn xuyên qua được chỉ là may.
//
//  CHỌN CÁCH I CHỨ KHÔNG CHỌN CÁCH H. Types #6 đo được hai cách chặn,
//  clipped() ngắn hơn, nhưng nó chỉ CẮT HÌNH chứ không sửa HỘP BAO của
//  mark. Vùng tô vẫn chạy từ đường giá xuống tận 0, mà gradient thì
//  resolve theo hộp bao — nên nấc nhạt rơi ra ngoài khung, trong khung
//  chỉ còn phần đậm, rồi clipped() cắt đúng cái phần đã nhạt đi.
//
//  yStart:yEnd: kéo hộp bao về trùng vùng vẽ, nên chữa cả hai chuyện một
//  lượt. Với vùng tô màu đặc thì hai cách như nhau; hễ có gradient thì
//  chỉ cách I đúng.
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
        y: .value("Giá", bar.close)
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
        Chart(bars) { bar in
          LineMark(
            x: .value("Ngày", bar.day),
            y: .value("Giá", bar.close)
          )
        }
        .frame(height: 240)
      } header: {
        Text("1 — LineMark trần")
      } footer: {
        Text("Chưa modifier nào. Charts tự quyết hết: trục Y bên trái kéo về chứa 0, nên cả năm biến động từ 243 tới 345 bị dồn vào một phần ba trên của khung. Màu xanh mặc định, nền theo List. Đây là chỗ xuất phát.")
      }

      Section {
        priceChart
          .frame(height: 240)
      } header: {
        Text("2 — miền khít, trục phải, gradient")
      } footer: {
        Text("Ba thay đổi. chartYScale lấy đúng min…max nên đường giá trải hết chiều cao — một mình nó làm nên phần lớn cái dáng Stocks. Trục sang phải, bốn mốc thôi. AreaMark tô gradient tắt dần rồi LineMark đè lên lấy nét sắc, vì Swift Charts không có kiểu area có viền. Nhãn trục X vẫn đọc được vì gradient tắt gần hẳn ở đáy, đúng cơ chế đã đo ở Types #6.")
      }

      Section {
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
        .frame(height: 240)
      } header: {
        Text("3 — neo đáy vùng tô vào cận dưới của miền")
      } footer: {
        Text("Chart 2 để vùng tô chạy từ đường giá xuống tận đường gốc 0, tức là xuống dưới cả khung. Hai hậu quả: nó phủ qua dải nhãn ngày, và gradient resolve theo HỘP BAO của mark nên nấc nhạt rơi ra ngoài vùng nhìn thấy — trong khung chỉ còn phần đậm. Đổi sang yStart:yEnd: thì hộp bao trùng đúng vùng vẽ: vùng tô dừng ở đáy khung, và gradient trải trọn từ đường giá xuống đáy, đúng cái nhạt dần của bản thật. Cách clipped() ở Types #6 chart H cắt được phần thò ra nhưng không sửa hộp bao, nên gradient vẫn sai.")
      }

      Section {
        priceChart
          .frame(height: 200)
          .environment(\.colorScheme, .dark)
      } header: {
        Text("4 — nền tối: environment cộng listRowBackground")
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
