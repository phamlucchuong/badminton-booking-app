import '/components/button/button_widget.dart';
import '/components/otp_digit_field/otp_digit_field_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/components/tab_group/tab_group_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/models/auth_models.dart';
import '/pages/home_dashboard/home_dashboard_widget.dart';
import '/services/api_exception.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'authentication_model.dart';
export 'authentication_model.dart';

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({super.key});

  static String routeName = 'Authentication';
  static String routePath = '/authentication';

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  late AuthenticationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // TextEditingControllers for form inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Whether we are on the OTP step (after successful register+sendOtp)
  bool _isOtpStep = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthenticationModel());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(24.0),
                                shape: BoxShape.rectangle,
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.sports_tennis_rounded,
                                color: FlutterFlowTheme.of(context).onPrimary,
                                size: 32.0,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'CourtDash',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                        lineHeight: 1.25,
                                      ),
                                ),
                                Text(
                                  'Book your winning shot',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                        child: Container(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.isSignup = !(_model.isSignup ?? true);
                              safeSetState(() {});
                              _model.error = '\"\"';
                              safeSetState(() {});
                            },
                            child: Container(
                              child: wrapWithModel(
                                model: _model.tabGroupModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TabGroupWidget(
                                  label1: 'Login',
                                  label2: 'Sign Up',
                                  label2Present: true,
                                  label3: 'Reports',
                                  label3Present: true,
                                  label4: '',
                                  label4Present: false,
                                  label5: '',
                                  label5Present: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_model.error != null && _model.error != '')
                            Text(
                              _model.error!,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                        ].divide(SizedBox(height: 24.0)),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Divider(
                                height: 16.0,
                                thickness: 1.0,
                                indent: 0.0,
                                endIndent: 0.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            Text(
                              'OR',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .onBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                    lineHeight: 1.3,
                                  ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Divider(
                                height: 16.0,
                                thickness: 1.0,
                                indent: 0.0,
                                endIndent: 0.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: wrapWithModel(
                              model: _model.socialAuthButtonModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: SocialAuthButtonWidget(
                                provider:
                                    'https://cdn.simpleicons.org/google/0f172a.svg',
                                label: 'Google',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: wrapWithModel(
                              model: _model.socialAuthButtonModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: SocialAuthButtonWidget(
                                provider:
                                    'https://cdn.simpleicons.org/apple/0f172a.svg',
                                label: 'Apple',
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                      Container(
                        height: 40.0,
                      ),
                      // ── Email/password form ──────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          borderRadius: BorderRadius.circular(24.0),
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color:
                                FlutterFlowTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              if (_model.isSignup ?? false)
                                _buildInputField(
                                  context: context,
                                  controller: _nameController,
                                  label: 'Full Name',
                                  hint: 'Enter your name',
                                  obscure: false,
                                ),
                              if (_model.isSignup ?? false)
                                SizedBox(height: 12.0),
                              _buildInputField(
                                context: context,
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email',
                                obscure: false,
                                keyboardType:
                                    TextInputType.emailAddress,
                                onChanged: (v) {
                                  _model.email = v;
                                },
                              ),
                              SizedBox(height: 12.0),
                              _buildInputField(
                                context: context,
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                obscure: true,
                                onChanged: (v) {
                                  _model.password = v;
                                },
                              ),
                              if (_model.isSignup ?? false)
                                SizedBox(height: 12.0),
                              if (_model.isSignup ?? false)
                                _buildInputField(
                                  context: context,
                                  controller: _phoneController,
                                  label: 'Phone',
                                  hint: 'Enter your phone number',
                                  obscure: false,
                                  keyboardType: TextInputType.phone,
                                ),
                              SizedBox(height: 20.0),
                              // ── Submit button ────────────────────────────
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // Sync text fields → model
                                  _model.email =
                                      _emailController.text.trim();
                                  _model.password =
                                      _passwordController.text;

                                  if (_model.isSignup ?? false) {
                                    // ── Sign-up flow ─────────────────────
                                    try {
                                      await FFAppState()
                                          .authRepository
                                          .register(
                                            RegisterRequest(
                                              name: _nameController
                                                  .text
                                                  .trim(),
                                              email: _model.email ??
                                                  '',
                                              password:
                                                  _model.password ??
                                                      '',
                                              phone: _phoneController
                                                  .text
                                                  .trim(),
                                            ),
                                          );
                                      await FFAppState()
                                          .authRepository
                                          .sendOtp(
                                              _model.email ?? '');
                                      if (context.mounted) {
                                        safeSetState(() {
                                          _isOtpStep = true;
                                          _model.otpCode = '';
                                        });
                                      }
                                    } on ApiException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.message),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // ── Login flow ───────────────────────
                                    try {
                                      await FFAppState()
                                          .authRepository
                                          .login(
                                            _model.email ?? '',
                                            _model.password ?? '',
                                          );
                                      FFAppState().update(() =>
                                          FFAppState().isLoggedIn =
                                              true);
                                      if (context.mounted) {
                                        context.goNamed(
                                            HomeDashboardWidget
                                                .routeName);
                                      }
                                    } on ApiException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.message),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: wrapWithModel(
                                  model: _model.buttonModel1,
                                  updateCallback: () =>
                                      safeSetState(() {}),
                                  child: ButtonWidget(
                                    content: (_model.isSignup ?? false)
                                        ? 'Create Account'
                                        : 'Log In',
                                    iconPresent: false,
                                    iconEndPresent: false,
                                    variant: 'primary',
                                    size: 'medium',
                                    fullWidth: true,
                                    loading: false,
                                    disabled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 24.0,
                      ),
                      if (_isOtpStep)
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Verify Email',
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                      Text(
                                        'We sent a 6-digit code to your email.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                  // OTP text input field
                                  TextField(
                                    controller: _otpController,
                                    maxLength: 6,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: (v) {
                                      _model.otpCode = v;
                                      safeSetState(() {});
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter 6-digit code',
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          width: 2.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 8.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                        ),
                                  ),
                                  // OTP digit display row (decorative)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 0)
                                              ? _model.otpCode![0]
                                              : '',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 1)
                                              ? _model.otpCode![1]
                                              : '',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 2)
                                              ? _model.otpCode![2]
                                              : '',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel4,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 3)
                                              ? _model.otpCode![3]
                                              : '',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel5,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 4)
                                              ? _model.otpCode![4]
                                              : '',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.otpDigitFieldModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: OtpDigitFieldWidget(
                                          value: (_model.otpCode != null &&
                                                  _model.otpCode!.length > 5)
                                              ? _model.otpCode![5]
                                              : '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Verify & Continue button (wired)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      if ((_model.otpCode ?? '').length < 6) {
                                        _model.error =
                                            'Please enter the full verification code';
                                        safeSetState(() {});
                                        return;
                                      }
                                      try {
                                        final ok = await FFAppState()
                                            .authRepository
                                            .verifyOtp(
                                              _model.email ?? '',
                                              _model.otpCode ?? '',
                                            );
                                        if (ok) {
                                          if (context.mounted) {
                                            safeSetState(() {
                                              _isOtpStep = false;
                                              _model.isSignup = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Email verified! Please log in.'),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Invalid verification code. Please try again.'),
                                              ),
                                            );
                                          }
                                        }
                                      } on ApiException catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.message),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: wrapWithModel(
                                      model: _model.buttonModel2,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ButtonWidget(
                                        content: 'Verify & Continue',
                                        iconPresent: false,
                                        iconEndPresent: false,
                                        variant: 'primary',
                                        size: 'medium',
                                        fullWidth: true,
                                        loading: false,
                                        disabled: false,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Didn\'t receive code?',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                      // Resend button (wired)
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          try {
                                            await FFAppState()
                                                .authRepository
                                                .sendOtp(_model.email ?? '');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Verification code resent.'),
                                                ),
                                              );
                                            }
                                          } on ApiException catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(e.message),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: wrapWithModel(
                                          model: _model.buttonModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ButtonWidget(
                                            content: 'Resend',
                                            iconPresent: false,
                                            iconEndPresent: false,
                                            variant: 'ghost',
                                            size: 'small',
                                            fullWidth: false,
                                            loading: false,
                                            disabled: false,
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 4.0)),
                                  ),
                                ].divide(SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(
                  fontWeight:
                      FlutterFlowTheme.of(context).labelSmall.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight:
                    FlutterFlowTheme.of(context).labelSmall.fontWeight,
                fontStyle:
                    FlutterFlowTheme.of(context).labelSmall.fontStyle,
              ),
        ),
        SizedBox(height: 6.0),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .fontWeight,
                    fontStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            contentPadding:
                EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight:
                      FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }
}
