//
//  AnimationTopicScreen.swift
//  Draft
//
//  Placeholder cho 11 nhóm chủ đề trong tài liệu Animations của Apple:
//  https://developer.apple.com/documentation/swiftui/animations
//
//  Mỗi màn chỉ liệt kê các symbol thuộc nhóm đó. Dựng demo dần sau.
//

import SwiftUI

enum AnimationTopic: String, CaseIterable, Identifiable, Hashable {
  case stateBasedAction
  case stateBasedView
  case phaseBased
  case keyframeBased
  case customAnimations
  case makingDataAnimatable
  case synchronizingGeometries
  case definingTransitions
  case matchedTransitions
  case navigationTransitions
  case movingAnimation

  var id: Self { self }

  var title: String {
    switch self {
    case .stateBasedAction:        "Adding state-based animation to an action"
    case .stateBasedView:          "Adding state-based animation to a view"
    case .phaseBased:              "Creating phase-based animation"
    case .keyframeBased:           "Creating keyframe-based animation"
    case .customAnimations:        "Creating custom animations"
    case .makingDataAnimatable:    "Making data animatable"
    case .synchronizingGeometries: "Synchronizing geometries"
    case .definingTransitions:     "Defining transitions"
    case .matchedTransitions:      "Defining matched transitions"
    case .navigationTransitions:   "Defining navigation transitions"
    case .movingAnimation:         "Moving an animation to another view"
    }
  }

  // Symbol chính của nhóm, để biết mỗi chủ đề đụng tới API nào.
  var symbols: [String] {
    switch self {
    case .stateBasedAction:
      ["withAnimation(_:_:)",
       "withAnimation(_:completionCriteria:_:completion:)",
       "AnimationCompletionCriteria",
       "Animation"]
    case .stateBasedView:
      ["animation(_:)",
       "animation(_:value:)",
       "animation(_:body:)"]
    case .phaseBased:
      ["phaseAnimator(_:content:animation:)",
       "phaseAnimator(_:trigger:content:animation:)",
       "PhaseAnimator"]
    case .keyframeBased:
      ["keyframeAnimator(initialValue:repeating:content:keyframes:)",
       "keyframeAnimator(initialValue:trigger:content:keyframes:)",
       "KeyframeAnimator",
       "Keyframes",
       "KeyframeTimeline",
       "KeyframeTrack",
       "CubicKeyframe",
       "LinearKeyframe",
       "MoveKeyframe",
       "SpringKeyframe"]
    case .customAnimations:
      ["CustomAnimation",
       "AnimationContext",
       "AnimationState",
       "AnimationStateKey",
       "UnitCurve",
       "Spring"]
    case .makingDataAnimatable:
      ["Animatable",
       "AnimatableValues",
       "AnimatablePair",
       "VectorArithmetic",
       "EmptyAnimatableData"]
    case .synchronizingGeometries:
      ["matchedGeometryEffect(id:in:properties:anchor:isSource:)",
       "MatchedGeometryProperties",
       "GeometryEffect",
       "Namespace",
       "geometryGroup()"]
    case .definingTransitions:
      ["transition(_:)",
       "Transition",
       "TransitionProperties",
       "TransitionPhase",
       "AsymmetricTransition",
       "AnyTransition",
       "contentTransition(_:)",
       "ContentTransition",
       "PlaceholderContentView"]
    case .matchedTransitions:
      ["matchedTransitionSource(id:in:)",
       "matchedTransitionSource(id:in:configuration:)",
       "MatchedTransitionSourceConfiguration",
       "EmptyMatchedTransitionSourceConfiguration"]
    case .navigationTransitions:
      ["navigationTransition(_:)",
       "NavigationTransition",
       "AnyNavigationTransition",
       "CrossFadeNavigationTransition"]
    case .movingAnimation:
      ["withTransaction(_:_:)",
       "withTransaction(_:_:_:)",
       "transaction(_:)",
       "transaction(value:_:)",
       "transaction(_:body:)",
       "Transaction",
       "TransactionKey"]
    }
  }
}

struct AnimationTopicScreen: View {
  let topic: AnimationTopic

  var body: some View {
    List {
      Section {
        ForEach(topic.symbols, id: \.self) { symbol in
          Text(symbol)
            .font(.system(.footnote, design: .monospaced))
            .padding(.vertical, 2)
        }
      } header: {
        Text("Symbols")
      } footer: {
        Text("Chưa dựng demo cho chủ đề này.")
      }
    }
    .navigationTitle(topic.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AnimationTopicScreen(topic: .makingDataAnimatable)
  }
}
