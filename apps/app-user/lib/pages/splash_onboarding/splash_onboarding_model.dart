import '/components/button/button_widget.dart';
import '/components/onboarding_slide/onboarding_slide_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'splash_onboarding_widget.dart' show SplashOnboardingWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashOnboardingModel extends FlutterFlowModel<SplashOnboardingWidget> {
  ///  State fields for stateful widgets in this page.

  PageController? pageViewController;
  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  // Model for OnboardingSlide 1.
  late OnboardingSlideModel onboardingSlideModel1;
  // Model for OnboardingSlide 2.
  late OnboardingSlideModel onboardingSlideModel2;
  // Model for OnboardingSlide 3.
  late OnboardingSlideModel onboardingSlideModel3;
  // Model for Button.
  late ButtonModel buttonModel1;

  @override
  void initState(BuildContext context) {
    onboardingSlideModel1 = createModel(context, () => OnboardingSlideModel());
    onboardingSlideModel2 = createModel(context, () => OnboardingSlideModel());
    onboardingSlideModel3 = createModel(context, () => OnboardingSlideModel());
    buttonModel1 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    onboardingSlideModel1.dispose();
    onboardingSlideModel2.dispose();
    onboardingSlideModel3.dispose();
    buttonModel1.dispose();
  }
}
