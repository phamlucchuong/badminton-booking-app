import '/components/button/button_widget.dart';
import '/components/otp_digit_field/otp_digit_field_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/auth_models.dart';
import '/pages/home_dashboard/home_dashboard_widget.dart';
import '/services/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _confirmPasswordController = TextEditingController();
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
    _confirmPasswordController.dispose();
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Icon
                        Center(
                          child: Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                            ),
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Icon(
                              Icons.sports_tennis_rounded,
                              color: FlutterFlowTheme.of(context).onPrimary,
                              size: 32.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Title / Subtitle
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
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
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
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).secondaryText,
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
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                        const SizedBox(height: 32.0),
                        if (_model.error != null && _model.error != '')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Center(
                              child: Text(
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
                            ),
                          ),
                        if (!_isOtpStep) ...[
                          // ── Email/password form ──────────────────────────
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
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Full Name Field (Sign up only)
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: (_model.isSignup ?? false)
                                        ? Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: _buildInputField(
                                              context: context,
                                              controller: _nameController,
                                              label: 'Full Name',
                                              hint: 'Enter your name',
                                              obscure: false,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  // Email Field (Always)
                                  _buildInputField(
                                    context: context,
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'Enter your email',
                                    obscure: false,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (v) {
                                      _model.email = v;
                                    },
                                  ),
                                  const SizedBox(height: 12.0),

                                  // Phone Field (Sign up only)
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: (_model.isSignup ?? false)
                                        ? Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: _buildInputField(
                                              context: context,
                                              controller: _phoneController,
                                              label: 'Phone',
                                              hint: 'Enter your phone number',
                                              obscure: false,
                                              keyboardType: TextInputType.phone,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  // Password Field (Always)
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

                                  // Forgot Password Field (Sign in only)
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: !(_model.isSignup ?? false)
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Forgot password functionality coming soon!'),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 4.0,
                                                  ),
                                                  child: Text(
                                                    'Forgot Password?',
                                                    style: FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          font: GoogleFonts.inter(),
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  // Confirm Password Field (Sign up only)
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: (_model.isSignup ?? false)
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: _buildInputField(
                                              context: context,
                                              controller: _confirmPasswordController,
                                              label: 'Confirm Password',
                                              hint: 'Re-confirm your password',
                                              obscure: true,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  const SizedBox(height: 20.0),

                                  // Submit button with stable GestureDetector on the outside
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      // Sync text fields → model
                                      _model.email = _emailController.text.trim();
                                      _model.password = _passwordController.text;

                                      debugPrint('[Auth] Button tapped! isSignup: ${_model.isSignup}');
                                      debugPrint('[Auth] Credentials: email: "${_model.email}", password length: ${_model.password?.length}');

                                      if (_model.isSignup ?? false) {
                                        // Confirm password check
                                        if (_passwordController.text != _confirmPasswordController.text) {
                                          debugPrint('[Auth] Validation failed: password mismatch');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Passwords do not match.'),
                                            ),
                                          );
                                          return;
                                        }
                                        // ── Sign-up flow ─────────────────
                                        try {
                                          debugPrint('[Auth] Registering user: ${_nameController.text.trim()}, ${_model.email}');
                                          await FFAppState()
                                              .authRepository
                                              .register(
                                                RegisterRequest(
                                                  name: _nameController.text.trim(),
                                                  email: _model.email ?? '',
                                                  password: _model.password ?? '',
                                                  phone: _phoneController.text.trim(),
                                                ),
                                              );
                                          debugPrint('[Auth] User registered successfully, sending OTP to ${_model.email}');
                                          await FFAppState()
                                              .authRepository
                                              .sendOtp(_model.email ?? '');
                                          debugPrint('[Auth] OTP sent successfully');
                                          if (context.mounted) {
                                            safeSetState(() {
                                              _isOtpStep = true;
                                              _model.otpCode = '';
                                            });
                                          }
                                        } on ApiException catch (e) {
                                          debugPrint('[Auth] ApiException during register: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(e.message),
                                              ),
                                            );
                                          }
                                        } catch (e, stack) {
                                          debugPrint('[Auth] Network/General error during register: $e\n$stack');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Connection error: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        // ── Login flow ───────────────────
                                        try {
                                          debugPrint('[Auth] Logging in user: ${_model.email}');
                                          await FFAppState()
                                              .authRepository
                                              .login(
                                                _model.email ?? '',
                                                _model.password ?? '',
                                              );
                                          debugPrint('[Auth] Login successful. Updating state.');
                                          FFAppState().update(() =>
                                              FFAppState().isLoggedIn = true);
                                          if (context.mounted) {
                                            debugPrint('[Auth] Navigating to HomeDashboardWidget');
                                            context.goNamed(
                                                HomeDashboardWidget.routeName);
                                          }
                                        } on ApiException catch (e) {
                                          debugPrint('[Auth] ApiException during login: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(e.message),
                                              ),
                                            );
                                          }
                                        } catch (e, stack) {
                                          debugPrint('[Auth] Network/General error during login: $e\n$stack');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Connection error: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: KeyedSubtree(
                                        key: ValueKey<bool>(_model.isSignup ?? false),
                                        child: wrapWithModel(
                                          model: _model.buttonModel1,
                                          updateCallback: () => safeSetState(() {}),
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
                                    ),
                                  ),

                                  const SizedBox(height: 20.0),

                                  // Toggle link between login and signup
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        (_model.isSignup ?? false)
                                            ? "Already have an account? "
                                            : "Don't have an account? ",
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                            ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _model.isSignup = !(_model.isSignup ?? false);
                                          _model.error = '';
                                          safeSetState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                          child: Text(
                                            (_model.isSignup ?? false)
                                                ? "Log In"
                                                : "Sign Up",
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.bold),
                                                  color: FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // OR Divider
                          Row(
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
                            ].divide(const SizedBox(width: 16.0)),
                          ),

                          const SizedBox(height: 24.0),

                          // Google OAuth Button only
                          wrapWithModel(
                            model: _model.socialAuthButtonModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: SocialAuthButtonWidget(
                              provider:
                                  'https://cdn.simpleicons.org/google/0f172a.svg',
                              label: 'Google',
                            ),
                          ),
                        ] else ...[
                          // OTP Step container
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
                              padding: const EdgeInsets.all(32.0),
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
                                        'We sent a 4-digit code to your email.',
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
                                    ].divide(const SizedBox(height: 8.0)),
                                  ),
                                  // OTP digit display Stack (Invisible TextField overlay on top of 4 digit fields)
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.otpDigitFieldModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: OtpDigitFieldWidget(
                                              value: (_model.otpCode != null &&
                                                      _model.otpCode!.isNotEmpty)
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
                                        ],
                                      ),
                                      Positioned.fill(
                                        child: Opacity(
                                          opacity: 0.0,
                                          child: TextField(
                                            controller: _otpController,
                                            maxLength: 4,
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) {
                                              _model.otpCode = v;
                                              safeSetState(() {});
                                            },
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Verify & Continue button (wired)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      debugPrint('[Auth] Verify OTP clicked. Code: "${_model.otpCode}"');
                                      if ((_model.otpCode ?? '').length < 4) {
                                        debugPrint('[Auth] OTP validation failed: length < 4');
                                        _model.error =
                                            'Please enter the full verification code';
                                        safeSetState(() {});
                                        return;
                                      }
                                      try {
                                        debugPrint('[Auth] Calling verifyOtp for email: ${_model.email}, code: ${_model.otpCode}');
                                        final ok = await FFAppState()
                                            .authRepository
                                            .verifyOtp(
                                              _model.email ?? '',
                                              _model.otpCode ?? '',
                                            );
                                        debugPrint('[Auth] verifyOtp result: $ok');
                                        if (ok) {
                                          if (context.mounted) {
                                            safeSetState(() {
                                              _isOtpStep = false;
                                              _model.isSignup = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Email verified! Please log in.'),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Invalid verification code. Please try again.'),
                                              ),
                                            );
                                          }
                                        }
                                      } on ApiException catch (e) {
                                        debugPrint('[Auth] ApiException during verifyOtp: $e');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.message),
                                            ),
                                          );
                                        }
                                      } catch (e, stack) {
                                        debugPrint('[Auth] Network/General error during verifyOtp: $e\n$stack');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Connection error: $e'),
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
                                                const SnackBar(
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
                                    ].divide(const SizedBox(width: 4.0)),
                                  ),
                                ].divide(const SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
