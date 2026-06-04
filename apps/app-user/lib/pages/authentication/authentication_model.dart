import '/components/button/button_widget.dart';
import '/components/otp_digit_field/otp_digit_field_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/components/tab_group/tab_group_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'authentication_widget.dart' show AuthenticationWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthenticationModel extends FlutterFlowModel<AuthenticationWidget> {
  ///  Local state fields for this page.

  String? email;

  String? password;

  String? otpCode;

  bool? isSignup = false;

  String? error;

  ///  State fields for stateful widgets in this page.

  // Model for TabGroup.
  late TabGroupModel tabGroupModel;
  // Model for SocialAuthButton.
  late SocialAuthButtonModel socialAuthButtonModel1;
  // Model for SocialAuthButton.
  late SocialAuthButtonModel socialAuthButtonModel2;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel1;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel2;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel3;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel4;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel5;
  // Model for OtpDigitField.
  late OtpDigitFieldModel otpDigitFieldModel6;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    tabGroupModel = createModel(context, () => TabGroupModel());
    socialAuthButtonModel1 =
        createModel(context, () => SocialAuthButtonModel());
    socialAuthButtonModel2 =
        createModel(context, () => SocialAuthButtonModel());
    otpDigitFieldModel1 = createModel(context, () => OtpDigitFieldModel());
    otpDigitFieldModel2 = createModel(context, () => OtpDigitFieldModel());
    otpDigitFieldModel3 = createModel(context, () => OtpDigitFieldModel());
    otpDigitFieldModel4 = createModel(context, () => OtpDigitFieldModel());
    otpDigitFieldModel5 = createModel(context, () => OtpDigitFieldModel());
    otpDigitFieldModel6 = createModel(context, () => OtpDigitFieldModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    tabGroupModel.dispose();
    socialAuthButtonModel1.dispose();
    socialAuthButtonModel2.dispose();
    otpDigitFieldModel1.dispose();
    otpDigitFieldModel2.dispose();
    otpDigitFieldModel3.dispose();
    otpDigitFieldModel4.dispose();
    otpDigitFieldModel5.dispose();
    otpDigitFieldModel6.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
