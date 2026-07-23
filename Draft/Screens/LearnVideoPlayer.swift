//
//  VideoPlayer.swift
//  Draft
//
//  Created by Lam Tran  on 24/6/26.
//

import SwiftUI
import AVKit
import PhotosUI
import UniformTypeIdentifiers

struct LearnVideoPlayer: View {

  @State var localVideoMp4Show = false
  @State var localVideoMovShow = false
  
  @State var remoteVideoShow = false

  var localPlayerMp4: AVPlayer {
    if let url = Bundle.main.url(forResource: "Cable-Pushdown-with-rope-attachment-Upper-Arms", withExtension: ".mp4") {
      return AVPlayer(url: url)
    }
    
    return AVPlayer()
  }
  
  var localPlayerMov: AVPlayer {
    // Bởi vì file có đuối là .MOV (uppercase) nên withExtension cũng phải là ".MOV"
    if let url = Bundle.main.url(forResource: "IMG_2105", withExtension: ".MOV") {
      return AVPlayer(url: url)
    }
    
    return AVPlayer()
  }
  
  var remotePlayer: AVPlayer {
    AVPlayer(
      url: URL(
        string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4"
      )!
    )
  }
  
  var body: some View {
    
    VStack(alignment: .leading, spacing: 12) {
      Button("Show Local Video .mp4") {
        localVideoMp4Show = true
      }
      
      Button("Show Local Video .MOV") {
        localVideoMovShow = true
      }
      Button("Show Remote Video") {
        remoteVideoShow = true
      }
      Button("Show Local Video .mp4 - But hide the Controls") {
        
      }
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .fullScreenCover(isPresented: $localVideoMp4Show) {
      // onDismiss
    } content: {
      VStack {
        closeButton(value: $localVideoMp4Show)

        VideoPlayer(player: localPlayerMp4)
          .frame(height: 300)
          .frame(maxHeight: .infinity)
      }
    }
    .fullScreenCover(isPresented: $localVideoMovShow) {
      // onDismiss
    } content: {
      VStack {
        closeButton(value: $localVideoMovShow)

        VideoPlayer(player: localPlayerMov)
          .frame(height: 300)
          .frame(maxHeight: .infinity)
      }
    }
    .fullScreenCover(isPresented: $remoteVideoShow) {
      // onDismiss
    } content: {
      VStack {
        closeButton(value: $remoteVideoShow)

        VideoPlayer(player: remotePlayer)
          .frame(height: 300)
          .frame(maxHeight: .infinity)
      }
    }
  }
  
  @ViewBuilder
  private func closeButton(value: Binding<Bool>) -> some View {
    Button {
      value.wrappedValue = false
    } label: {
      Label("Close", systemImage: "xmark")
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color.black.opacity(0.05), in: Capsule())
    }
  }
}

#Preview {
  LearnVideoPlayer()
}
