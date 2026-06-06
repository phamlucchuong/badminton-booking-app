import '/components/button/button_widget.dart';
import '/components/court_header/court_header_widget.dart';
import '/components/grid_slot/grid_slot_widget.dart';
import '/components/time_header/time_header_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/court.dart';
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

  late Future<List<Court>> _courtsFuture;
  final Set<String> _selectedKeys = {}; // '${courtId}:${slotIndex}'
  List<Court>? _loadedCourts;

  double _calculateTotal() {
    if (_loadedCourts == null || _loadedCourts!.isEmpty) {
      return 0.0;
    }
    double total = 0.0;
    for (final slot in FFAppState().selectedSlots) {
      final courtId = slot['courtId'] as String?;
      if (courtId != null) {
        final court = _loadedCourts!.firstWhere(
          (c) => c.id == courtId,
          orElse: () => _loadedCourts!.first,
        );
        total += court.pricePerHour;
      }
    }
    return total;
  }

  bool _isSelected(String courtId, int slotIndex) =>
      _selectedKeys.contains('$courtId:$slotIndex');

  void _toggleSlot(String courtId, int slotIndex) {
    final key = '$courtId:$slotIndex';

    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
      final allSlots = _selectedKeys.map((k) {
        final sep = k.lastIndexOf(':');
        final cId = k.substring(0, sep);
        final idx = int.parse(k.substring(sep + 1));
        final sh = 8 + idx;
        final court = _loadedCourts?.firstWhere(
          (c) => c.id == cId,
          orElse: () => _loadedCourts!.first,
        );
        return <String, dynamic>{
          'courtId': cId,
          'startTime': '${sh.toString().padLeft(2, '0')}:00:00',
          'endTime': '${(sh + 1).toString().padLeft(2, '0')}:00:00',
          'price': court?.pricePerHour ?? 20.0,
        };
      }).toList();
      FFAppState().update(() => FFAppState().selectedSlots = allSlots);
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeSlotMatrixModel());
    FFAppState().currentVenueId = widget.courtId ?? '';
    FFAppState().update(() => FFAppState().selectedSlots = []);
    FFAppState().currentBookingDate =
        DateTime.now().toIso8601String().split('T').first;
    _courtsFuture =
        FFAppState().venueRepository.getCourts(widget.courtId ?? '');
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
        body: SafeArea(
          child: Column(
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
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.goNamed(HomeDashboardWidget.routeName);
                                }
                              },
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  context.l10n('Select Time Slot', 'Chọn khung giờ'),
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
                                  () {
                                    try {
                                      final parsed = DateTime.parse(FFAppState().currentBookingDate);
                                      final isVi = FFAppState().language.toUpperCase() == 'VI';
                                      return DateFormat(isVi ? 'dd/MM' : 'EEE, MMM d').format(parsed);
                                    } catch (_) {
                                      return context.l10n('Select Date', 'Chọn ngày');
                                    }
                                  }(),
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
                              onPressed: () async {
                                final current = DateTime.tryParse(FFAppState().currentBookingDate) ?? DateTime.now();
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: current,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    FFAppState().currentBookingDate = picked.toIso8601String().split('T').first;
                                  });
                                }
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
                            context.l10n('Available', 'Còn trống'),
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
                            context.l10n('Selected', 'Đang chọn'),
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
                            context.l10n('Booked', 'Đã đặt'),
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
              child: FutureBuilder<List<Court>>(
                future: _courtsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(context.l10n('Failed to load courts', 'Tải danh sách sân thất bại'),
                          style: FlutterFlowTheme.of(context).bodyMedium),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                   final courts = snapshot.data!;
                  _loadedCourts = courts;
                  final timeLabels = List.generate(
                      10, (i) => '${(8 + i).toString().padLeft(2, '0')}:00');
                  return SingleChildScrollView(
                    primary: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            ...courts.map((c) => CourtHeaderWidget(name: c.name)),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: timeLabels
                                      .map((t) => TimeHeaderWidget(time: t))
                                      .toList(),
                                ),
                                ...courts.map(
                                  (court) => Row(
                                    children: List.generate(10, (slotIdx) {
                                      final selected =
                                          _isSelected(court.id, slotIdx);
                                      return GestureDetector(
                                        onTap: () =>
                                            _toggleSlot(court.id, slotIdx),
                                        child: GridSlotWidget(
                                            state: selected
                                                ? 'selected'
                                                : 'available'),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n('${FFAppState().selectedSlots.length} Slots Selected', 'Đã chọn ${FFAppState().selectedSlots.length} ô giờ'),
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
                                  () {
                                    final total = _calculateTotal();
                                    return '${total.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ ' + context.l10n('Total', 'Tổng cộng');
                                  }(),
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
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(ReviewOrderWidget.routeName);
                            },
                            child: wrapWithModel(
                              model: _model.buttonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonWidget(
                                content: context.l10n('Confirm Booking', 'Xác nhận đặt sân'),
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
      ),
    );
  }
}
