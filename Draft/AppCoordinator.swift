//
//  AppCoordinator.swift
//  Draft
//

import SwiftUI

@Observable
class AppCoordinator {
    var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop(_ steps: Int = 1) {
        path.removeLast(min(steps, path.count))
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func replace(_ route: AppRoute) {
        path = NavigationPath()
        path.append(route)
    }
}

enum AppRoute: Hashable {
    case scrollViewSafeArea
    case contentMarginsPlayground
    case fixedHeightBottomSheet
    case dynamicHeightBottomSheet
    case dynamicHeightBottomSheetiOS18
    case localizeDaytime
    case canonicalValue
    case fullScreenCover
    case learnVideo
    case learnPhotoPicker
    case keyboardLab
    case keyboardBaseline
    case keyboardTracking
    case keyboardAccessory
    case keyboardLayoutGuide
    case sideMenuLab
    case markdownLab
    case markdownText
    case markdownAttributedString
    case markdownSwiftMarkdown
    case learnAnimation
    case animationBasics
    case animationCurves
    case animationTransitions
    case animationPhaseKeyframe
    case swipeToConfirm
    case kavsoftSlideToConfirm
    case lineHeightExact
    case observationLab
    case languagePicker
    case snackBarLab
    case toastLab
}

extension AppRoute: View {
    var body: some View {
        switch self {
        case .scrollViewSafeArea:
            ScrollViewSafeAreaView()
        case .contentMarginsPlayground:
            ContentMarginsPlaygroundView()
        case .fixedHeightBottomSheet:
            FixedHeightBottomSheet()
        case .dynamicHeightBottomSheet:
            DynamicHeightBottomSheet_iOS_16()
        case .dynamicHeightBottomSheetiOS18:
            DynamicHeightBottomSheet_iOS_18()
        case .localizeDaytime:
            LocalizeDatetime()
        case .canonicalValue:
            LearnCanonicalValue()
        case .fullScreenCover:
            FullScreenCover()
        case .learnVideo:
            LearnVideoPlayer()
        case .learnPhotoPicker:
            LearnPhotoPicker()
        case .keyboardLab:
            KeyboardLab()
        case .keyboardBaseline:
            BaselineScreen()
        case .keyboardTracking:
            TrackingScreen()
        case .keyboardAccessory:
            AccessoryScreen()
        case .keyboardLayoutGuide:
            KeyboardLayoutGuideScreen()
        case .sideMenuLab:
            SideMenuLab()
        case .markdownLab:
            MarkdownLab()
        case .markdownText:
            MarkdownTextScreen()
        case .markdownAttributedString:
            MarkdownAttributedStringScreen()
        case .markdownSwiftMarkdown:
            MarkdownSwiftMarkdownScreen()
        case .learnAnimation:
            LearnAnimation()
        case .animationBasics:
            AnimationBasicsScreen()
        case .animationCurves:
            AnimationCurvesScreen()
        case .animationTransitions:
            AnimationTransitionsScreen()
        case .animationPhaseKeyframe:
            AnimationPhaseKeyframeScreen()
        case .swipeToConfirm:
            SwipeToConfirm()
        case .kavsoftSlideToConfirm:
            Kavsoft_SlideToConfirm()
        case .lineHeightExact:
            LineHeightExactScreen()
        case .observationLab:
            ObservationLab()
        case .languagePicker:
            LanguagePickerScreen()
        case .snackBarLab:
            SnackBarLab()
        case .toastLab:
            DemoToastFirstView()
        }
    }
}
