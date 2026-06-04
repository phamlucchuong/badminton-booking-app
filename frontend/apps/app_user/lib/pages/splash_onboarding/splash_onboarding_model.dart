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

  // Model for OnboardingSlide.
  late OnboardingSlideModel onboardingSlideModel;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    onboardingSlideModel = createModel(context, () => OnboardingSlideModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    onboardingSlideModel.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
