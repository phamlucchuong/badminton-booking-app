import 'dart:async';
import '/components/button/button_widget.dart';
import '/components/onboarding_slide/onboarding_slide_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'splash_onboarding_model.dart';
export 'splash_onboarding_model.dart';

class SplashOnboardingWidget extends StatefulWidget {
  const SplashOnboardingWidget({super.key});

  static String routeName = 'SplashOnboarding';
  static String routePath = '/splashOnboarding';

  @override
  State<SplashOnboardingWidget> createState() => _SplashOnboardingWidgetState();
}

class _SplashOnboardingWidgetState extends State<SplashOnboardingWidget> {
  late SplashOnboardingModel _model;
  Timer? _timer;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashOnboardingModel());
    _model.pageViewController = PageController(initialPage: 0);

    // Auto-scroll every 3 seconds in a loop
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_model.pageViewController != null &&
          _model.pageViewController!.hasClients) {
        final nextPage = (_model.pageViewCurrentIndex + 1) % 3;
        _model.pageViewController!.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.pageViewController?.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          alignment: AlignmentDirectional(-1.0, -1.0),
          children: [
            Align(
              alignment: AlignmentDirectional(1.0, -1.0),
              child: Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary5,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(9999.0),
                  ),
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          Container(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Container(
                                child: Container(
                                  alignment: AlignmentDirectional(1.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          FFAppState().language =
                                              FFAppState().language == 'EN'
                                                  ? 'VI'
                                                  : 'EN';
                                          FFAppState().update(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            shape: BoxShape.rectangle,
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 4.0, 8.0, 4.0),
                                            child: Container(
                                              child: Text(
                                                FFAppState().language,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                      lineHeight: 1.3,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      FlutterFlowIconButton(
                                        borderRadius: 10.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        icon: Icon(
                                          Icons.help,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          FFAppState().darkMode =
                                              !FFAppState().darkMode;
                                          FFAppState().update(() {});
                                        },
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 32.0),
                              child: Container(
                                child: Container(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          shape: BoxShape.rectangle,
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.sports_tennis_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onPrimary,
                                          size: 40.0,
                                        ),
                                      ),
                                      Text(
                                        'CourtDash',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w800,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: PageView(
                                    controller: _model.pageViewController,
                                    onPageChanged: (_) => safeSetState(() {}),
                                    children: [
                                      wrapWithModel(
                                        model: _model.onboardingSlideModel1,
                                        updateCallback: () => safeSetState(() {}),
                                        child: OnboardingSlideWidget(
                                          imageDesc: 'assets/images/onboarding_1.png',
                                          title: 'Find Your Perfect Court',
                                          description:
                                              'Browse and book top-rated badminton courts in your city with just a few taps.',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.onboardingSlideModel2,
                                        updateCallback: () => safeSetState(() {}),
                                        child: OnboardingSlideWidget(
                                          imageDesc: 'assets/images/onboarding_2.png',
                                          title: 'Easy Booking',
                                          description:
                                              'Check availability in real-time and secure your slot instantly without any hassle.',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.onboardingSlideModel3,
                                        updateCallback: () => safeSetState(() {}),
                                        child: OnboardingSlideWidget(
                                          imageDesc: 'assets/images/onboarding_3.png',
                                          title: 'Play & Connect',
                                          description:
                                              'Join local communities, find playing partners, and level up your game.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  final isSelected = _model.pageViewCurrentIndex == index;
                                  return AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: isSelected ? 24.0 : 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).alternate,
                                      borderRadius: BorderRadius.circular(9999.0),
                                    ),
                                  );
                                }).divide(SizedBox(width: 4.0)),
                              ),
                              ].divide(SizedBox(height: 32.0)),
                            ),
                          ),
                          Container(
                            height: 40.0,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.goNamed(
                                        AuthenticationWidget.routeName);
                                  },
                                  child: wrapWithModel(
                                    model: _model.buttonModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ButtonWidget(
                                      content: 'Start',
                                      iconPresent: false,
                                      iconEndPresent: false,
                                      variant: 'primary',
                                      size: 'large',
                                      fullWidth: false,
                                      loading: false,
                                      disabled: false,
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                          Container(
                            height: 20.0,
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 0.0,
              height: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
