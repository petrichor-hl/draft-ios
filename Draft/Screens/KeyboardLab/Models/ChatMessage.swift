//
//  ChatMessage.swift
//  Draft
//
//  Created by Lam Tran  on 7/7/26.
//

import Foundation

struct ChatMessage: Hashable, Identifiable {
  let id = UUID()
  let text: String
  let isMine: Bool   // true = mình (phải), false = người kia (trái)
}

let sampleMessages: [ChatMessage] = [
  ChatMessage(text: "Hey! You free this weekend?", isMine: false),
  ChatMessage(text: "Yeah, what's up?", isMine: true),
  ChatMessage(text: "Thinking of hiking Saturday morning", isMine: false),
  ChatMessage(text: "Nice", isMine: true),
  ChatMessage(text: "There's a trail near the lake, about 8km, not too hard — but the views at the top are unreal. We could grab coffee after too.", isMine: false),
  ChatMessage(text: "I'm in 👍", isMine: true),
  ChatMessage(text: "Awesome. Start around 7?", isMine: false),
  ChatMessage(text: "7 is early 😅 can we do 8?", isMine: true),
  ChatMessage(text: "Sure, 8 works", isMine: false),
  ChatMessage(text: "Cool. Should I bring anything?", isMine: true),
  ChatMessage(text: "Just water and maybe some snacks. I'll bring the trail map and a small first aid kit just in case.", isMine: false),
  ChatMessage(text: "Perfect", isMine: true),
  ChatMessage(text: "Oh and wear proper shoes — some parts get muddy after all the rain last week.", isMine: false),
  ChatMessage(text: "Got it, my trail runners should be fine", isMine: true),
  ChatMessage(text: "👍", isMine: false),
  ChatMessage(text: "By the way, did you ever finish that book you were reading?", isMine: true),
  ChatMessage(text: "Almost! Like 3 chapters left. The ending is getting so intense, I stayed up way too late last night.", isMine: false),
  ChatMessage(text: "Haha same, I couldn't put it down either", isMine: true),
  ChatMessage(text: "We should do a book swap sometime", isMine: false),
  ChatMessage(text: "Yes! I've got a few you'd probably like", isMine: true),
  ChatMessage(text: "Deal", isMine: false),
  ChatMessage(text: "Anyway, see you Saturday. I'll text you when I leave.", isMine: true),
  ChatMessage(text: "Sounds good. Don't be late 😄", isMine: false),
  ChatMessage(text: "Me? Never.", isMine: true),
  ChatMessage(text: "Uh huh 🙄", isMine: false),
  ChatMessage(text: "Okay okay, I'll set two alarms", isMine: true),
  ChatMessage(text: "Now that's commitment 😂", isMine: false),
  ChatMessage(text: "Anything for a good hike and a decent cup of coffee afterwards", isMine: true),
  ChatMessage(text: "See you then!", isMine: false),
  ChatMessage(text: "See you! 🥾", isMine: true),
]
