import '/components/button/button_widget.dart';
import '/components/court_header/court_header_widget.dart';
import '/components/grid_slot/grid_slot_widget.dart';
import '/components/time_header/time_header_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'time_slot_matrix_model.dart';
export 'time_slot_matrix_model.dart';

class TimeSlotMatrixWidget extends StatefulWidget {
  const TimeSlotMatrixWidget({
    super.key,
    this.courtId,
  });

  final String? courtId;

  static String routeName = 'TimeSlotMatrix';
  static String routePath = '/timeSlotMatrix';

  @override
  State<TimeSlotMatrixWidget> createState() => _TimeSlotMatrixWidgetState();
}

class _TimeSlotMatrixWidgetState extends State<TimeSlotMatrixWidget> {
  late TimeSlotMatrixModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeSlotMatrixModel());
  }

  @override
  void dispose() {
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.pop();
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Select Time Slot',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                              Text(
                                'Sat, Oct 28',
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
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
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
                            ],
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.calendar_today_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: () {
                              print('IconButton pressed ...');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).surfaceVariant30,
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(4.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            'Available',
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
                        ].divide(SizedBox(width: 4.0)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(4.0),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          Text(
                            'Selected',
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
                        ].divide(SizedBox(width: 4.0)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).surfaceVariant,
                              borderRadius: BorderRadius.circular(4.0),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          Text(
                            'Booked',
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
                        ].divide(SizedBox(width: 4.0)),
                      ),
                    ].divide(SizedBox(width: 24.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: AlignmentDirectional(-1.0, -1.0),
                children: [
                  SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40.0,
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 1',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 2',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 3',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 4',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 5',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel6,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 6',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel7,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 7',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel8,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 8',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel9,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 9',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.courtHeaderModel10,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CourtHeaderWidget(
                                    name: 'Court 10',
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: SingleChildScrollView(
                                  primary: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.timeHeaderModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '08:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '09:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '10:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '11:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel5,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '12:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel6,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '13:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel7,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '14:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel8,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '15:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel9,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '16:00',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.timeHeaderModel10,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TimeHeaderWidget(
                                              time: '17:00',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.gridSlotModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'selected',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel5,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel6,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel7,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel8,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel9,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel10,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.gridSlotModel11,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel12,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel13,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel14,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'selected',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel15,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel16,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel17,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel18,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel19,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel20,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.gridSlotModel21,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel22,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel23,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel24,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel25,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel26,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel27,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel28,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel29,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel30,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.gridSlotModel31,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel32,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel33,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel34,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel35,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel36,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel37,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'selected',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel38,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'selected',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel39,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel40,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          wrapWithModel(
                                            model: _model.gridSlotModel41,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel42,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel43,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel44,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'unavailable',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel45,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel46,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel47,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel48,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel49,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                          wrapWithModel(
                                            model: _model.gridSlotModel50,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: GridSlotWidget(
                                              state: 'available',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${FFAppState().selectedSlots.length.toString()} Slots Selected',
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                              Text(
                                '\$\${app.selected_slots.length * 20}.00 Total',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                            ],
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.goNamed(ReviewOrderWidget.routeName);
                            },
                            child: wrapWithModel(
                              model: _model.buttonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonWidget(
                                content: 'Confirm Booking',
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
