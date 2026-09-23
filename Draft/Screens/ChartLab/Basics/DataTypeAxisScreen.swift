//
//  DataTypeAxisScreen.swift
//  Draft
//
//  ĐỀ BÀI — cùng một tuần dữ liệu, đưa vào trục X bằng ba kiểu khác nhau:
//    String ("T2")  → band scale, mỗi giá trị một dải rộng bằng nhau
//    Int (2)        → linear scale, khoảng cách giữa các số có ý nghĩa
//    Date           → time scale, Charts tự chọn đơn vị nhãn theo locale
//
//  Câu hỏi đắt nhất: bỏ một ngày ra khỏi mảng thì chuyện gì xảy ra?
//  Band scale coi như ngày đó chưa từng tồn tại; linear và time để lại
//  đúng một khoảng trống. Đây là lý do chart nhịp tim phải dùng Date.
//
//  ĐÃ ĐO trên simulator, cùng một mảng 5 phần tử:
//
//                      nhãn trục X            bề rộng cột    mép khung
//    String            T2…T6                  rộng           có lề hai bên
//    Int               0, 2, 4                que tăm        cột cuối dính mép
//    Date + unit:.day  21 thg 9, 23, 25       rộng           gần sát mép
//    Date không unit   21…24, rụng nhãn 25    que tăm        cột cuối dính mép
//
//  1. Int làm mất sạch ý nghĩa: đưa vào 2…6 với ý "thứ Hai đến thứ Sáu",
//     Charts đọc ra mấy con số rồi tự chọn mốc chẵn 0, 2, 4.
//
//  2. Trục X kiểu Int cũng kéo miền về 0 — trống hẳn hai đơn vị bên trái
//     trước cột đầu tiên. Vậy quy tắc đo được ở màn 1 rộng hơn ta tưởng:
//     MỌI trục kiểu số đều gồm 0, không riêng trục Y. Trục Date thì không,
//     nó bám quanh vùng dữ liệu — time scale là scale riêng, không phải
//     linear đội lốt.
//
//  3. unit: quyết định bề rộng cột. Thiếu nó, mỗi Date là một thời điểm
//     không bề dày nên Charts vẽ cột hẹp nhất có thể, đồng thời rải nhãn
//     mỗi ngày rồi hết chỗ, rụng mất nhãn cuối.
//
//  4. "21 thg 9" là locale Việt đang làm việc, không có dòng format nào.
//
//  KHUYẾT DỮ LIỆU — band scale nói dối. Bốn cột T2, T3, T5, T6 đứng khít
//  và còn béo ra vì bốn dải chia hết khung: biểu đồ tự lấp chỗ trống, xoá
//  vết tích cuối cùng của ngày thiếu. Bản Date để lại đúng một khoảng
//  trống rộng một ngày ở 23 thg 9.
//
//  Toạ độ đến từ đâu quyết định tất cả: band scale chỉ đếm số phần tử
//  trong mảng, time scale có trục thời gian thật làm hệ quy chiếu.
//
//  CẢNH BÁO cho màn Line: điều trên chỉ đúng với BarMark. LineMark trên
//  cùng trục Date đó vẫn kẻ thẳng từ 22 sang 24, vắt ngang khoảng trống.
//  Chart Garmin cần cả hai: Date để đặt đúng chỗ, VÀ tách series để đường
//  chịu đứt ra.
//

import Charts
import SwiftUI

struct DayPoint: Identifiable {
  let id = UUID()
  let label: String   // "T2"
  let index: Int      // 2
  let date: Date      // 21/09/2026 là thứ Hai
  let steps: Int
}

private let weekPoints: [DayPoint] = {
  let calendar = Calendar.current
  let monday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 21))!
  return [6200, 8100, 4300, 9500, 7200].enumerated().map { offset, steps in
    DayPoint(
      label: "T\(offset + 2)",
      index: offset + 2,
      date: calendar.date(byAdding: .day, value: offset, to: monday)!,
      steps: steps
    )
  }
}()

private let weekWithGap: [DayPoint] = weekPoints.filter { $0.label != "T4" }

struct DataTypeAxisScreen: View {
  var body: some View {
    List {
      Section("String → band scale") {
        Chart(weekPoints) { item in
          BarMark(
            x: .value("Thứ", item.label),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 200)
      }

      Section("Int → linear scale") {
        Chart(weekPoints) { item in
          BarMark(
            x: .value("Thứ", item.index),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 200)
      }

      Section("Date + unit: .day") {
        Chart(weekPoints) { item in
          BarMark(
            x: .value("Ngày", item.date, unit: .day),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 200)
      }
      
      Divider()

      Section("Date, không unit:") {
        Chart(weekPoints) { item in
          BarMark(
            x: .value("Ngày", item.date),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 200)
      }
      
      Divider()
      
      Section {
        Chart(weekWithGap) { item in
          BarMark(x: .value("Thứ", item.label), y: .value("Bước", item.steps))
        }
        .frame(height: 200)
      } header: {
        Text("String, khuyết T4")
      } footer: {
        Text("Không có vị trí trống cho T4")
      }

      Section {
        Chart(weekWithGap) { item in
          BarMark(x: .value("Ngày", item.date, unit: .day), y: .value("Bước", item.steps))
        }
        .frame(height: 200)
      } header: {
        Text("Date + unit:, khuyết T4")
      } footer: {
        Text("Có vị trí trống cho T4")
      }
    }
  }
}
