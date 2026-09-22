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
    case scrollViewLab
    case scrollViewSafeArea
    case scrollViewContentMargins
    case scrollViewSwipeActions
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
    case animationTopics
    case animationTopic(AnimationTopic)
    case fabExpand
    case fabSeparateDialog
    case stagger
    case swipeToConfirm
    case kavsoftSlideToConfirm
    case fixedSize
    case lineHeightExact
    case observationLab
    case languagePicker
    case snackBarLab
    case toastLab
    case doubleSheetLab
    case doubleSheetChained
    case doubleSheetSibling
    case doubleSheetItem
    case doubleCover
    case sheetAndCover
    case coverAndSheetReversed
    case hapticsLab
    case hapticsSensory
    case hapticsGenerator
    case hapticsPrepare
    case hapticsImpact
    case hapticsNotification
    case hapticsSelection
    case hapticsLocation
    case hapticsOutsideView
    case hapticsCore
    case hapticsRealWorld
    case wheelPickerLab
    case flowRow
    case accordion
    case accordionBuiltIn
    case accordionSingle
    case accordionMultiExpand
    case accordionSingleOpen
    case calendarLab
    case calendar
    case calendariOS18
    case logger
    case cameraLab
    case cameraPermission
    case cameraImagePicker
    case cameraSessionPreview
    case cameraPhotoCapture
    case cameraControls
    case cameraVideoRecording
    case cameraMetadataScan
    case cameraVideoDataOutput
    case cameraAdvanced
}

extension AppRoute: View {
    var body: some View {
        switch self {
        case .scrollViewLab:
            ScrollViewLab()
        case .scrollViewSafeArea:
            ScrollViewSafeAreaScreen()
        case .scrollViewContentMargins:
            ContentMarginsScreen()
        case .scrollViewSwipeActions:
            Kavsoft_SwipeActionsForScrollView()
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
        case .animationTopics:
            AnimationTopicsScreen()
        case .animationTopic(let topic):
            AnimationTopicScreen(topic: topic)
        case .fabExpand:
            FABExpandScreen()
        case .fabSeparateDialog:
            FABSeparateDialogScreen()
        case .stagger:
            StaggerScreen()
        case .swipeToConfirm:
            SwipeToConfirm()
        case .kavsoftSlideToConfirm:
            Kavsoft_SlideToConfirm()
        case .fixedSize:
            FixedSizeScreen()
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
        case .doubleSheetLab:
            DoubleSheetLab()
        case .doubleSheetChained:
            ChainedSheetScreen()
        case .doubleSheetSibling:
            SiblingSheetScreen()
        case .doubleSheetItem:
            SingleSheetItemScreen()
        case .doubleCover:
            DoubleCoverScreen()
        case .sheetAndCover:
            SheetAndCoverScreen()
        case .coverAndSheetReversed:
            CoverAndSheetReversedScreen()
        case .hapticsLab:
            HapticsLab()
        case .hapticsSensory:
            SensoryFeedbackScreen()
        case .hapticsGenerator:
            GeneratorScreen()
        case .hapticsPrepare:
            PrepareLatencyScreen()
        case .hapticsImpact:
            ImpactStyleScreen()
        case .hapticsNotification:
            NotificationTypeScreen()
        case .hapticsSelection:
            SelectionScreen()
        case .hapticsLocation:
            LocationFeedbackScreen()
        case .hapticsOutsideView:
            OutsideViewScreen()
        case .hapticsCore:
            CoreHapticsScreen()
        case .wheelPickerLab:
            WheelPickerLabScreen()
        case .hapticsRealWorld:
            RealWorldScreen()
        case .flowRow:
            FlowRowScreen()
        case .accordion:
            AccordionLab()
        case .accordionBuiltIn:
            DisclosureGroupScreen()
        case .accordionSingle:
            SingleAccordionScreen()
        case .accordionMultiExpand:
            MultiExpandAccordionScreen()
        case .accordionSingleOpen:
            SingleOpenAccordionScreen()
        case .calendarLab:
            CalendarLab()
        case .calendar:
            CalendarScreen_iOS_16()
        case .calendariOS18:
            CalendarScreen_iOS_18()
        case .logger:
            LoggerScreen()
        case .cameraLab:
            CameraLab()
        case .cameraPermission:
            CameraPermissionScreen()
        case .cameraImagePicker:
            ImagePickerCameraScreen()
        case .cameraSessionPreview:
            SessionPreviewScreen()
        case .cameraPhotoCapture:
            PhotoCaptureScreen()
        case .cameraControls:
            CameraControlsScreen()
        case .cameraVideoRecording:
            VideoRecordingScreen()
        case .cameraMetadataScan:
            MetadataScanScreen()
        case .cameraVideoDataOutput:
            VideoDataOutputScreen()
        case .cameraAdvanced:
            AdvancedCaptureScreen()
        }
    }
}
