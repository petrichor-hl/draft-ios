//
//  AnnotationScreen.swift
//  Draft
//
//  ĐỀ BÀI — annotation là cửa thoát DUY NHẤT khỏi thế giới ChartContent.
//
//  Từ màn 1: bên trong Chart { } chỉ nhận Mark, nhét Text vào là compile
//  error. Nhưng closure của .annotation nhận View bình thường — Text, Image,
//  HStack, RoundedRectangle, bất cứ thứ gì SwiftUI vẽ được.
//
//    .annotation(position:alignment:spacing:) { ... }
//      position: .top / .bottom / .leading / .trailing / .overlay
//                .topLeading / … / .automatic
//
//  Là modifier của MARK, không phải của chart: mỗi mark một annotation
//  riêng, neo vào đúng vị trí mark đó.
//
//  ĐÃ ĐO trên simulator, năm ngày, cột cao nhất 9.500.
//
//  ANNOTATION ĂN VÀO DOMAIN. Charts nới miền trục Y về phía annotation nằm:
//    A  .top      trục nới LÊN 15.000
//    B  .overlay  trục giữ nguyên 10.000 — nhãn đè lên mark nên không tốn chỗ
//    C  .bottom   trục nới XUỐNG −5.000, dù dữ liệu không có giá trị âm nào
//
//  Hệ quả thực tế: gắn nhãn vào cột là biểu đồ tự thu nhỏ lại. Và nếu đang
//  khoá chartYScale thì Charts hết đường nới — nhãn sẽ bị cắt thay vì được
//  chừa chỗ.
//
//  C — .bottom NEO VÀO ĐÁY CỦA MARK, không phải đáy khung. Nhãn cam nằm sát
//  chân cột ở mức 0, còn nhãn trục X tụt xuống đáy miền mới là −5.000. Hai
//  hàng cách nhau một quãng lớn, trông như lỗi nhưng đúng logic.
//
//  Vì vậy .bottom gần như vô dụng với BarMark: vừa tạo miền âm vô nghĩa,
//  vừa tranh chỗ với trục X. Nó hợp với PointMark hay LineMark hơn, nơi mark
//  không dính đáy.
//
//  Ghi chú về cách đo: ban đầu nội dung annotation ở C là Text(item.day) —
//  trùng hệt nhãn trục X nên hai hàng giống nhau như đúc, không phân biệt
//  được cái nào là cái nào. Đổi sang số bước và tô cam thì tách bạch ngay.
//  Bài học: để biến quan sát trùng với biến đối chứng thì không đo được gì.
//
//  D, E — ANNOTATION BỊ BÓ CHIỀU RỘNG THEO MARK. Label "9.500" kèm icon bị
//  cắt còn "9." vì rộng hơn bề ngang cột. Thêm .fixedSize() là View giữ kích
//  thước tự nhiên và tràn sang hai bên — cùng cơ chế với FixedSizeScreen.
//
//  D cũng cho thấy annotation gắn được CÓ ĐIỀU KIỆN, vì nó là modifier của
//  mark: chỉ ngày nhiều bước nhất mới có nhãn.
//

import Charts
import SwiftUI

struct DayStep: Identifiable {
  let id = UUID()
  let day: String
  let steps: Int
}

private let week: [DayStep] = [
  .init(day: "T2", steps: 6200),
  .init(day: "T3", steps: 8100),
  .init(day: "T4", steps: 4300),
  .init(day: "T5", steps: 9500),
  .init(day: "T6", steps: 7200),
]

private let bestDay = week.max { $0.steps < $1.steps }

struct AnnotationScreen: View {
  var body: some View {
    List {
      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
          .annotation(position: .top) {
            Text("\(item.steps)")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        .frame(height: 240)
      } header: {
        Text("A — position: .top")
      } footer: {
        Text("Nhãn nằm trên đầu cột. Để ý cột cao nhất: nhãn có bị đẩy tràn khỏi khung, hay Charts tự chừa chỗ cho nó?")
      }

      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
          .annotation(position: .overlay) {
            Text("\(item.steps)")
              .font(.caption2)
              .foregroundStyle(.white)
          }
        }
        .frame(height: 240)
      } header: {
        Text("B — position: .overlay")
      } footer: {
        Text("Nhãn đè LÊN cột nên không chiếm thêm chỗ. Chữ đổi sang trắng vì nền cột đậm — annotation không tự biết nó đang nằm trên nền gì.")
      }

      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
          .annotation(position: .bottom) {
            Text("↑\(item.steps)")
              .font(.caption2)
              .foregroundStyle(.orange)
          }
        }
        .frame(height: 240)
      } header: {
        Text("C — position: .bottom")
      } footer: {
        Text("Nhãn cam là annotation, neo vào ĐÁY CỦA MARK tức mức 0 — ngay dưới chân cột. Nhãn xám T2…T6 là trục X, bị đẩy xuống đáy KHUNG. Charts nới miền xuống −5.000 để chừa chỗ, nên hai hàng cách nhau một quãng lớn.")
      }

      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
          .foregroundStyle(item.id == bestDay?.id ? Color.orange : Color.blue)
          .annotation(position: .top) {
            if item.id == bestDay?.id {
              Label("\(item.steps)", systemImage: "flame.fill")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange, in: Capsule())
            }
          }
        }
        .frame(height: 240)
      } header: {
        Text("D — annotation có điều kiện, View thật")
      } footer: {
        Text("annotation là modifier của MARK nên gắn được có điều kiện — chỉ ngày nhiều bước nhất mới có nhãn. Closure nhận View bình thường: Label, padding, background, Capsule. NHƯNG chữ bị cắt thành \"9.\" — annotation bị bó chiều rộng theo bề ngang của mark.")
      }

      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
          .foregroundStyle(item.id == bestDay?.id ? Color.orange : Color.blue)
          .annotation(position: .top) {
            if item.id == bestDay?.id {
              Label("\(item.steps)", systemImage: "flame.fill")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange, in: Capsule())
                .fixedSize()
            }
          }
        }
        .frame(height: 240)
      } header: {
        Text("E — thêm .fixedSize()")
      } footer: {
        Text("Giống D, thêm đúng một dòng. fixedSize() bảo View giữ kích thước tự nhiên, không chịu bó theo bề ngang mark — nhãn hiện đủ chữ và tràn sang hai bên cột.")
      }

    }
    .navigationTitle("Annotation")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AnnotationScreen()
  }
}
