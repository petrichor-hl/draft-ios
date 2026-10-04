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
    case safeAreaInsetLab
    case safeAreaInsetDynamicHeight
    case safeAreaInsetKeyboard
    case safeAreaLab
    case maskLab
    case shimmerSkeletonLab
    case formLab
    case formPassword
    case formLeadingIcon
    case formNumericInput
    case formAutofill
    case formKeyboardAvoidance
    case formInitialFocus
    case formNextFocus
    case formFocusedBorder
    case formValidation
    case formSubmission
    case otpVerificationLab
    case otpSingleField
    case otpSegmentedAppearance
    case otpSeparateFields
    case otpPaste
    case otpAutofill
    case otpFocus
    case otpVerificationStates
    case otpResend
    case otpCompleteFlow
    case safeAreaPadding
    case safeAreaBar
    case ignoresSafeArea
    case safeAreaBackground
    case safeAreaOverlay
    case edgesIgnoringSafeArea
    case scrollViewSafeArea
    case scrollViewContentMargins
    case scrollViewSwipeActions
    case scrollViewFixedHeight
    case scrollViewCappedHeight
    case scrollViewMaxHeight
    case scrollViewMaxHeightInSheet
    case bottomSheetLab
    case fixedHeightBottomSheet
    case dynamicHeightBottomSheet
    case dynamicHeightBottomSheetiOS18
    case textFieldInSheet
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
    case keyboardToolbarDone
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
    case segmentedControl
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
    case biometricAuthenticationLab
    case cameraPermission
    case cameraImagePicker
    case cameraSessionPreview
    case cameraUIKitPresentation
    case cameraSessionPreset
    case cameraPhotoCapture
    case cameraControls
    case cameraVideoRecording
    case cameraMetadataScan
    case cameraVideoDataOutput
    case cameraAdvanced
    case cameraDietfit
    case cameraBitePal
    case menuLab
    case menuWithLabeledContent
    case chartLab
    case chartBasics
    case chartAnatomy
    case chartDataTypeAxis
    case chartModifierLayers
    case chartByScale
    case chartAxisCustom
    case chartAnnotation
    case chartBackgroundRegion
    case chartRuleMark
    case chartHelloSwiftCharts
    case chartCupertinoDetails
    case chartLocationsToggle
    case chartLocationDetails
    case chartRaiseTheBar
    case chartLocationDetailsBarMark
    case chartExplorePieChartsAndInteractivity
    case chartExplorePieCharts
    case chartInteractivity
    case chartTypes
    case chartColumn
    case chartBar
    case chartLine
    case chartInterpolation
    case chartArea
    case chartPoint
    case chartPieDonut
    case chartRange
    case chartHeatmap
    case chartInteraction
    case chartStepsSelection
    case chartToolbox
    case chartAppleHealthSteps
    case chartGarminHeartRate
    case chartStocks
    case chartViewPerMonth
    case sliderToolbox
    case reorderListLab
    case reorderTwoWaysEditActions
    case reorderTwoWaysOnMove
    case reorderOnMove
    case reorderEditActions
    case reorderLockedRows
    case reorderCustomGesture
}

extension AppRoute: View {
    var body: some View {
        switch self {
        case .scrollViewLab:
            ScrollViewLab()
        case .safeAreaInsetLab:
            SafeAreaInsetLab()
        case .safeAreaInsetDynamicHeight:
            SafeAreaInsetDynamicHeightScreen()
        case .safeAreaInsetKeyboard:
            SafeAreaInsetKeyboardScreen()
        case .safeAreaLab:
            SafeAreaLab()
        case .maskLab:
            MaskLab()
        case .shimmerSkeletonLab:
            ShimmerSkeletonLab()
        case .formLab:
            FormLab()
        case .formPassword:
            FormPasswordScreen()
        case .formLeadingIcon:
            FormLeadingIconScreen()
        case .formNumericInput:
            FormNumericInputScreen()
        case .formAutofill:
            FormAutofillScreen()
        case .formKeyboardAvoidance:
            FormKeyboardAvoidanceScreen()
        case .formInitialFocus:
            FormInitialFocusScreen()
        case .formNextFocus:
            FormNextFocusScreen()
        case .formFocusedBorder:
            FormFocusedBorderScreen()
        case .formValidation:
            FormValidationScreen()
        case .formSubmission:
            FormSubmissionScreen()
        case .otpVerificationLab:
            OTPVerificationLab()
        case .otpSingleField:
            OTPSingleFieldScreen()
        case .otpSegmentedAppearance:
            OTPSegmentedAppearanceScreen()
        case .otpSeparateFields:
            OTPSeparateFieldsScreen()
        case .otpPaste:
            OTPPasteScreen()
        case .otpAutofill:
            OTPAutofillScreen()
        case .otpFocus:
            OTPFocusScreen()
        case .otpVerificationStates:
            OTPVerificationStatesScreen()
        case .otpResend:
            OTPResendScreen()
        case .otpCompleteFlow:
            OTPCompleteFlowScreen()
        case .safeAreaPadding:
            SafeAreaPaddingScreen()
        case .safeAreaBar:
            SafeAreaBarScreen()
        case .ignoresSafeArea:
            IgnoresSafeAreaScreen()
        case .safeAreaBackground:
            SafeAreaBackgroundScreen()
        case .safeAreaOverlay:
            SafeAreaOverlayScreen()
        case .edgesIgnoringSafeArea:
            EdgesIgnoringSafeAreaScreen()
        case .scrollViewSafeArea:
            ScrollViewSafeAreaScreen()
        case .scrollViewContentMargins:
            ContentMarginsScreen()
        case .scrollViewSwipeActions:
            Kavsoft_SwipeActionsForScrollView()
        case .scrollViewFixedHeight:
            FixedHeightScrollScreen()
        case .scrollViewCappedHeight:
            CappedHeightScrollScreen()
        case .scrollViewMaxHeight:
            MaxHeightScrollScreen()
        case .scrollViewMaxHeightInSheet:
            MaxHeightInSheetScreen()
        case .bottomSheetLab:
            BottomSheetLab()
        case .fixedHeightBottomSheet:
            FixedHeightBottomSheet()
        case .dynamicHeightBottomSheet:
            DynamicHeightBottomSheet_iOS_16()
        case .dynamicHeightBottomSheetiOS18:
            DynamicHeightBottomSheet_iOS_18()
        case .textFieldInSheet:
            TextFieldInSheet()
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
        case .keyboardToolbarDone:
            ToolbarDoneScreen()
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
        case .segmentedControl:
            SegmentedControlScreen()
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
        case .biometricAuthenticationLab:
            BiometricAuthenticationLab()
        case .cameraPermission:
            CameraPermissionScreen()
        case .cameraImagePicker:
            ImagePickerCameraScreen()
        case .cameraSessionPreview:
            SessionPreviewScreen()
        case .cameraUIKitPresentation:
            UIKitCameraPresentationScreen()
        case .cameraSessionPreset:
            SessionPresetScreen()
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
        case .cameraDietfit:
            DietfitCameraScreen()
        case .cameraBitePal:
            BitePalCameraScreen()
        case .menuLab:
            MenuLab()
        case .menuWithLabeledContent:
            MenuWithLabeledContent()
        case .chartLab:
            ChartLab()
        case .chartBasics:
            ChartBasicsLab()
        case .chartAnatomy:
            ChartAnatomyScreen()
        case .chartDataTypeAxis:
            DataTypeAxisScreen()
        case .chartModifierLayers:
            ModifierLayersScreen()
        case .chartByScale:
            ByScaleScreen()
        case .chartAxisCustom:
            AxisCustomScreen()
        case .chartAnnotation:
            AnnotationScreen()
        case .chartBackgroundRegion:
            BackgroundRegionScreen()
        case .chartRuleMark:
            RuleMarkScreen()
        case .chartHelloSwiftCharts:
            HelloSwiftCharts()
        case .chartCupertinoDetails:
            CupertinoDetails()
        case .chartLocationsToggle:
            LocationsToggle()
        case .chartLocationDetails:
            LocationDetails()
        case .chartRaiseTheBar:
            RaiseTheBar()
        case .chartLocationDetailsBarMark:
            LocationDetailsBarMark()
        case .chartExplorePieChartsAndInteractivity:
            ExplorePieChartsAndInteractivity()
        case .chartExplorePieCharts:
            ExplorePieCharts()
        case .chartInteractivity:
            Interactivity()
        case .chartTypes:
            ChartTypesLab()
        case .chartColumn:
            ColumnChartScreen()
        case .chartBar:
            BarChartScreen()
        case .chartLine:
            LineChartScreen()
        case .chartInterpolation:
            LineInterpolationScreen()
        case .chartArea:
            AreaChartScreen()
        case .chartPoint:
            PointChartScreen()
        case .chartPieDonut:
            PieDonutScreen()
        case .chartRange:
            RangeChartScreen()
        case .chartHeatmap:
            HeatmapScreen()
        case .chartInteraction:
            ChartInteractionLab()
        case .chartStepsSelection:
            StepsSelectionScreen()
        case .chartToolbox:
            ChartToolbox()
        case .chartAppleHealthSteps:
            AppleHealthStepsScreen()
        case .chartGarminHeartRate:
            GarminHeartRateScreen()
        case .chartStocks:
            StocksScreen()
        case .chartViewPerMonth:
            ViewPerMonthScreen()
        case .sliderToolbox:
            SliderToolbox()
        case .reorderListLab:
            ReorderListLab()
        case .reorderTwoWaysEditActions:
            TwoWaysEditActionsScreen()
        case .reorderTwoWaysOnMove:
            TwoWaysOnMoveScreen()
        case .reorderOnMove:
            OnMoveReorderScreen()
        case .reorderEditActions:
            EditActionsReorderScreen()
        case .reorderLockedRows:
            LockedRowsReorderScreen()
        case .reorderCustomGesture:
            CustomGestureReorderScreen()
        }
    }
}
