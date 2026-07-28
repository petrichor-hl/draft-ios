//
//  LearnPhotoPicker.swift
//  Draft
//
//  Created by Lam Tran  on 24/6/26.
//

import SwiftUI
import AVKit
import PhotosUI
import CoreTransferable



struct LearnPhotoPicker: View {
  @State private var imageItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var isImageLoading = false
  
  @State private var videoItem: PhotosPickerItem?
  @State private var hasVideo = false
  @State private var isVideoLoading = false
  @State private var player = AVPlayer()
  
  @State private var mediaItem: PhotosPickerItem?
  
  var body: some View {
    VStack {
      
      
      if let selectedImage = selectedImage {
        Image(uiImage: selectedImage)
          .resizable()
          .scaledToFill()
          .frame(height: 250)
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay {
            if isImageLoading {
              ProgressView()
                .controlSize(.large)
                .tint(.white)
            }
          }
      } else {
        Group {
          if isImageLoading {
            ProgressView()
              .controlSize(.large)
          } else {
            Text("No image selected")
          }
        }
        .foregroundStyle(Color.gray.s500)
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
              Color.gray.s500,
              style: StrokeStyle(lineWidth: 1, dash: [10])
            )
        )
      }
      
      if hasVideo {
        VideoPlayer(player: player)
          .frame(height: 250)
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay {
            if isVideoLoading {
              ProgressView()
                .controlSize(.large)
                .tint(.white)
            }
          }
      } else {
        Group {
          if isVideoLoading {
            ProgressView()
              .controlSize(.large)
          } else {
            Text("No video selected")
          }
        }
        .foregroundStyle(Color.gray.s500)
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
              Color.gray.s500,
              style: StrokeStyle(lineWidth: 1, dash: [10])
            )
        )
      }
      
      HStack {
        PhotosPicker(
          selection: $imageItem,
          matching: .images
        ) {
          Text("Image from Gallery")
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.blue, in: Capsule())
        }
        
        PhotosPicker(
          selection: $videoItem,
          matching: .videos
        ) {
          Text( "Video from Gallery")
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.blue, in: Capsule())
        }
      }
      .foregroundStyle(Color.white)
      
      PhotosPicker(
        selection: $mediaItem,
        matching: .any(of: [.images, .videos])
      ) {
        Text("Media from Gallery")
          .foregroundStyle(Color.white)
          .frame(height: 48)
          .frame(maxWidth: .infinity)
          .background(Color.blue, in: Capsule())
      }
      
      
    }
    .padding()
    .onChange(of: imageItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        isImageLoading = true
        defer { isImageLoading = false }
        
        if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
          selectedImage = image
        }
      }
    }
    .onChange(of: videoItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        isVideoLoading = true
        defer { isVideoLoading = false }
        
        // Copy video ra file tạm để AVPlayer phát được
        if let movie = try? await newItem.loadTransferable(type: Movie.self) {
          player.replaceCurrentItem(with: AVPlayerItem(url: movie.url))
          hasVideo = true
        }
      }
    }
    .onChange(of: mediaItem) { _, newItem in
      guard let newItem else { return }
      Task {
        let isVideo = newItem.supportedContentTypes.contains {
          $0.conforms(to: .movie)
        }
        if isVideo {
          isVideoLoading = true
          defer { isVideoLoading = false }
          if let movie = try? await newItem.loadTransferable(type: Movie.self) {
            player.replaceCurrentItem(with: AVPlayerItem(url: movie.url))
            hasVideo = true
          }
        } else {
          isImageLoading = true
          defer { isImageLoading = false }
          if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
            selectedImage = image
          }
        }
      }
    }
  }
}

struct Movie: Transferable {
  let url: URL
  
  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { received in
      let copy = URL.documentsDirectory.appending(path: "movie-\(UUID().uuidString).mov")
      if FileManager.default.fileExists(atPath: copy.path()) {
        try FileManager.default.removeItem(at: copy)
      }
      try FileManager.default.copyItem(at: received.file, to: copy)
      return Self(url: copy)
    }
  }
}

#Preview {
  LearnPhotoPicker()
}
