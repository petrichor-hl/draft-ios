//
//  ColumnChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — cột dọc: BarMark(x: category, y: value).
//    .cornerRadius            bo đầu cột
//    width: .fixed / .ratio   bề rộng cột, thay vì để Charts tự tính
//    .position(by:)           tách nhóm nằm cạnh nhau (grouped)
//    nhiều BarMark cùng x      xếp chồng lên nhau (stacked) — mặc định
//
//  Column và Bar là CÙNG MỘT BarMark; khác nhau duy nhất ở chỗ category
//  nằm ở trục X hay trục Y. So sánh với BarChartScreen.
//
//  Basics #1 đã vẽ cột trần một chuỗi. Màn này bắt đầu từ chỗ có NHIỀU
//  hàng cùng rơi vào một x — lúc đó Charts phải quyết định làm gì với
//  chúng, và quyết định mặc định là chồng lên nhau.
//
//  ĐÃ ĐO trên simulator. Mảng nguồn cố ý để lộn xộn, mỗi quý một thứ tự
//  kênh khác nhau, và chính nó lôi ra cái bẫy lớn nhất của màn này.
//
//  THỨ TỰ CHỒNG LẤY TỪ MẢNG, KHÔNG LẤY TỪ SCALE MÀU. Chart A chồng đúng
//  theo thứ tự các hàng xuất hiện trong mảng: Q1 xanh lá dưới cùng, Q2
//  xanh dương, Q3 cam. Cùng một màu nhảy lên nhảy xuống giữa các cột, mắt
//  không dóng ngang được. Legend thì vẫn một thứ tự cố định — hai cơ chế
//  khác nhau, và chúng không buộc phải khớp.
//
//  Nên: stacked chỉ đọc được khi mảng nguồn đã sắp nhất quán. Không có
//  modifier nào sửa hộ, phải sort trước khi đưa vào Chart (chart B).
//
//  Nhưng sort xong thì MÀU ĐỔI THEO, vì miền của scale màu cũng dựng theo
//  lần xuất hiện đầu tiên: xanh dương đang là Online bỗng thành Cửa hàng,
//  và năm chart trong màn này không còn nói cùng một ngôn ngữ. Cách chữa
//  là ghim miền lại bằng chartForegroundStyleScale(domain:) — cả năm chart
//  ở đây đều ghim, nên màu giờ cố định bất kể mảng sắp thế nào.
//
//  GROUPED MIỄN NHIỄM. Chart C vẫn dùng mảng lộn xộn của A mà quý nào
//  cũng đúng thứ tự Online – Cửa hàng – Đại lý, vì .position(by:) lấy chỗ
//  từ MIỀN của một scale dùng chung cho cả chart, chứ không xét từng x
//  một như stacking. Một lý do nữa để chọn grouped khi không kiểm soát
//  được nguồn dữ liệu.
//
//  Và scale vị trí đó KHÁC scale màu: ghim chartForegroundStyleScale đổi
//  màu của ba kênh nhưng không đụng gì tới thứ tự nhóm trong chart C —
//  thứ tự đó vẫn là lần xuất hiện đầu tiên trong mảng. Hai miền riêng,
//  đặt tên giống nhau trong .value() cũng không gộp chúng lại.
//
//  .normalized ĐỔI TRỤC Y SANG THANG 0–100, và KHÔNG tự thêm dấu %. Muốn
//  có dấu % thì phải tự format nhãn trục.
//
//  cornerRadius BO ĐỈNH CẢ CỘT, không bo từng khúc. Các khúc bên trong
//  vẫn phẳng, không hở khe, chân cột vẫn vuông. Khác với dự đoán ban đầu
//  là mỗi khúc tự bo bốn góc rồi cột rời ra thành từng miếng.
//

import Charts
import SwiftUI

private struct ChannelSales: Identifiable {
  let id = UUID()
  let quarter: String
  let channel: String
  let revenue: Int
}

/// Bốn quý, ba kênh bán. Mỗi quý một thứ tự kênh khác nhau — giống dữ
/// liệu thật trả về từ API, không ai bảo đảm thứ tự. Đơn vị: triệu đồng.
private let sales: [ChannelSales] = [
  .init(quarter: "Q1", channel: "Online", revenue: 80),
  .init(quarter: "Q1", channel: "Cửa hàng", revenue: 120),
  .init(quarter: "Q1", channel: "Đại lý", revenue: 45),

  .init(quarter: "Q2", channel: "Cửa hàng", revenue: 135),
  .init(quarter: "Q2", channel: "Đại lý", revenue: 50),
  .init(quarter: "Q2", channel: "Online", revenue: 110),

  .init(quarter: "Q3", channel: "Đại lý", revenue: 48),
  .init(quarter: "Q3", channel: "Online", revenue: 145),
  .init(quarter: "Q3", channel: "Cửa hàng", revenue: 128),

  .init(quarter: "Q4", channel: "Online", revenue: 190),
  .init(quarter: "Q4", channel: "Cửa hàng", revenue: 160),
  .init(quarter: "Q4", channel: "Đại lý", revenue: 60),
]

private let channelOrder = ["Cửa hàng", "Online", "Đại lý"]

/// Sắp theo quý, trong mỗi quý sắp theo channelOrder. Đây là thứ duy nhất
/// ra lệnh được cho thứ tự xếp chồng.
private let sortedSales: [ChannelSales] = sales.sorted { left, right in
  if left.quarter != right.quarter {
    return left.quarter < right.quarter
  }
  let leftIndex = channelOrder.firstIndex(of: left.channel) ?? 0
  let rightIndex = channelOrder.firstIndex(of: right.channel) ?? 0
  return leftIndex < rightIndex
}

struct ColumnChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(sales) { item in
          BarMark(
            x: .value("Quý", item.quarter),
            y: .value("Doanh thu", item.revenue)
          )
          .foregroundStyle(by: .value("Kênh", item.channel))
        }
        .chartForegroundStyleScale(domain: channelOrder)
        .frame(height: 260)
      } header: {
        Text("A — ba hàng cùng một x, không nói gì thêm")
      } footer: {
        Text("Charts CHỒNG chúng lên nhau, không hỏi ai — stacked là mặc định của BarMark. Nhưng nhìn kỹ thứ tự: Q1 xanh lá dưới cùng, Q2 xanh dương, Q3 cam. Chồng theo thứ tự các hàng TRONG MẢNG, mà mảng thì lộn xộn. Cùng một màu nhảy lên nhảy xuống giữa các cột, mắt không dóng ngang được.")
      }

      Section {
        Chart(sortedSales) { item in
          BarMark(
            x: .value("Quý", item.quarter),
            y: .value("Doanh thu", item.revenue)
          )
          .foregroundStyle(by: .value("Kênh", item.channel))
        }
        .chartForegroundStyleScale(domain: channelOrder)
        .frame(height: 260)
      } header: {
        Text("B — vẫn chart A, nhưng sort mảng trước")
      } footer: {
        Text("Không thêm modifier nào, chỉ đưa vào mảng đã sắp theo quý rồi theo kênh. Giờ Cửa hàng luôn nằm dưới cùng, cột nào cũng vậy, mắt dóng ngang được. Không có modifier nào sửa hộ việc này — thứ tự chồng chỉ nghe lời mảng nguồn.")
      }

      Section {
        Chart(sales) { item in
          BarMark(
            x: .value("Quý", item.quarter),
            y: .value("Doanh thu", item.revenue)
          )
          .foregroundStyle(by: .value("Kênh", item.channel))
          .position(by: .value("Kênh", item.channel))
        }
        .chartForegroundStyleScale(domain: channelOrder)
        .frame(height: 260)
      } header: {
        Text("C — .position(by:) → grouped")
      } footer: {
        Text("Chú ý: chart này dùng lại mảng LỘN XỘN của A, vậy mà quý nào cũng đúng thứ tự Online – Cửa hàng – Đại lý. position(by:) lấy chỗ từ MIỀN của scale chứ không từ mảng, nên miễn nhiễm với cái bẫy ở trên. Chồng để đọc TỔNG, tách để so sánh từng kênh — và tách thì an toàn hơn.")
      }

      Section {
        Chart(sortedSales) { item in
          BarMark(
            x: .value("Quý", item.quarter),
            y: .value("Doanh thu", item.revenue),
            stacking: .normalized
          )
          .foregroundStyle(by: .value("Kênh", item.channel))
        }
        .chartForegroundStyleScale(domain: channelOrder)
        .frame(height: 260)
      } header: {
        Text("D — stacking: .normalized")
      } footer: {
        Text("Mọi cột cao bằng nhau, giá trị tuyệt đối biến mất, chỉ còn TỈ TRỌNG: Online nở dần qua bốn quý trong khi Cửa hàng co lại — điều chart A giấu mất vì quý nào cột cũng cao hơn quý trước. Trục Y đổi sang thang 0–100 nhưng KHÔNG tự thêm dấu %, muốn có thì phải tự format nhãn.")
      }

      Section {
        Chart(sortedSales) { item in
          BarMark(
            x: .value("Quý", item.quarter),
            y: .value("Doanh thu", item.revenue),
            width: .ratio(0.5)
          )
          .foregroundStyle(by: .value("Kênh", item.channel))
          .cornerRadius(6)
        }
        .chartForegroundStyleScale(domain: channelOrder)
        .frame(height: 260)
      } header: {
        Text("E — width: .ratio(0.5) và .cornerRadius(6)")
      } footer: {
        Text("width nhận .automatic, .fixed(pt), .ratio(phần của dải) hoặc .inset(pt). .ratio(0.5) cho cột chiếm nửa dải, chừa nửa làm khe. cornerRadius thì bo ĐỈNH cả cột chứ không bo từng khúc: các khúc bên trong vẫn phẳng, không hở khe, chân cột vẫn vuông.")
      }
    }
    .navigationTitle("Column")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ColumnChartScreen()
  }
}
