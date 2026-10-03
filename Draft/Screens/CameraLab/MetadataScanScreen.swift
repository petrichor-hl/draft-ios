//
//  MetadataScanScreen.swift
//  Draft
//
//  Phần 8 — Quét QR / barcode.
//
//  Sẽ học:
//  - AVCaptureMetadataOutput + metadataObjectTypes = [.qr, .ean13, ...].
//  - Delegate trả AVMetadataMachineReadableCodeObject: có cả chuỗi lẫn toạ độ 4 góc.
//  - transformedMetadataObject(for:) để vẽ khung đúng chỗ trên preview.
//  - rectOfInterest — giới hạn vùng quét, vừa nhanh hơn vừa đỡ quét nhầm.
//  - Chống bắn trùng: cùng một mã sẽ được trả về liên tục mỗi frame.
//  - So sánh với DataScannerViewController (VisionKit) — dễ hơn nhưng kén máy.
//

import SwiftUI

struct MetadataScanScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "qrcode.viewfinder",
      description: Text("Phần 8 — AVCaptureMetadataOutput.")
    )
    .navigationTitle("8. Quét mã")
    .navigationBarTitleDisplayMode(.inline)
  }
}
