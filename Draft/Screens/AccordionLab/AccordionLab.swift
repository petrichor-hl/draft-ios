//
//  AccordionLab.swift
//  Draft
//
//  Accordion: header bấm được, body co giãn. Lab đi theo thứ tự "biết hàng có
//  sẵn trước, rồi mới tự dựng" — mỗi bước một màn riêng.
//
//  Ghi chú thuật ngữ: nhiều tài liệu UX chỉ gọi là ACCORDION khi mở cái này
//  thì cái kia tự đóng (mục 4). Loại mở tự do (mục 3) tên đúng hơn là
//  collapsible / disclosure. Ở đây gọi chung cho gọn.
//
//  Trong cả lab, chỉ có HAI thứ thật sự đổi CODE: state nằm ở đâu, và có cho
//  đóng hết hay không. Còn lại — chevron trái hay phải, +/− hay mũi tên, card
//  rời hay khối liền — chỉ là lớp áo, xem mục 5.
//

import SwiftUI

struct AccordionLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("Hàng có sẵn") {
        Button {
          coordinator.push(.accordionBuiltIn)
        } label: {
          LabRow(
            title: "1. DisclosureGroup",
            subtitle: "Bản tự giữ state, bản isExpanded:, và label tuỳ biến"
          )
        }
      }

      Section("Tự dựng") {
        Button {
          coordinator.push(.accordionSingle)
        } label: {
          LabRow(
            title: "2. Một cái đơn lẻ",
            subtitle: "@State, if, withAnimation — có công tắc tắt từng thứ"
          )
        }

        LabRow(title: "3. Cụm mở tự do", subtitle: "Chưa dựng — xếp lại là xong, bẫy ở identity")
        LabRow(title: "4. Cụm single-open", subtitle: "Chưa dựng — state leo lên cha, ID?")
      }

      Section {
        LabRow(title: "5. Đổi lớp áo", subtitle: "Chưa dựng — chevron ↔ +/−, trái ↔ phải")
      } footer: {
        Text("Mục 3–5 dựng dần, mỗi mục một màn riêng.")
      }
    }
    .navigationTitle("Accordion Lab")
  }
}

// MARK: - Row

private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    AccordionLab()
      .environment(AppCoordinator())
  }
}
