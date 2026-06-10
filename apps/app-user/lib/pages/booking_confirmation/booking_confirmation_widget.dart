import '/components/booking_detail_row/booking_detail_row_widget.dart';
import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'booking_confirmation_model.dart';

export 'booking_confirmation_model.dart';

class BookingConfirmationWidget extends StatefulWidget {
  const BookingConfirmationWidget({super.key});

  static String routeName = 'BookingConfirmation';
  static String routePath = '/bookingConfirmation';

  @override
  State<BookingConfirmationWidget> createState() =>
      _BookingConfirmationWidgetState();
}

class _BookingConfirmationWidgetState extends State<BookingConfirmationWidget> {
  late BookingConfirmationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BookingConfirmationModel());
  }

  @override
  void dispose() {
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
        body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 32.0),
                    child: Container(
                      child: Container(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.network(
                              'https://dimg.dreamflow.cloud/v1/lottie/success+checkmark+animation',
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.contain,
                              repeat: false,
                              animate: true,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  context.l10n('Booking Confirmed!', 'Đặt sân thành công!'),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FlutterFlowTheme.of(context)
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
                                  context.l10n('Your court is ready for action', 'Sân của bạn đã sẵn sàng'),
                                  textAlign: TextAlign.center,
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
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final booking = FFAppState().currentBooking;
                      if (booking == null) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Center(
                            child: Text(
                              context.l10n('No booking data available', 'Không có dữ liệu đặt sân'),
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ),
                        );
                      }
                      // Format time: '10:00:00' → '10:00'
                      String fmtTime(String t) {
                        final parts = t.split(':');
                        if (parts.length < 2) return t;
                        return '${parts[0]}:${parts[1]}';
                      }
                      // Format amount: 150000.0 → '150,000'
                      String fmtAmt(double amt) {
                        final n = amt.toInt();
                        final s = n.toString();
                        final buffer = StringBuffer();
                        for (int i = 0; i < s.length; i++) {
                          if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
                          buffer.write(s[i]);
                        }
                        return buffer.toString();
                      }
                      final timeDisplay = '${fmtTime(booking.startTime)} - ${fmtTime(booking.endTime)}';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                            shape: BoxShape.rectangle,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking.courtName,
                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context).onPrimary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_rounded, color: FlutterFlowTheme.of(context).onPrimary80, size: 14.0),
                                              Text(
                                                booking.venueName,
                                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).onPrimary80,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                              ),
                                            ].divide(const SizedBox(width: 4.0)),
                                          ),
                                        ].divide(const SizedBox(height: 4.0)),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).onPrimary,
                                          borderRadius: BorderRadius.circular(10.0),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                                          child: Text(
                                            '${fmtAmt(booking.totalAmount)} VND',
                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context).primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    wrapWithModel(
                                      model: _model.bookingDetailRowModel1,
                                      updateCallback: () => safeSetState(() {}),
                                      child: BookingDetailRowWidget(
                                        icon: Icon(Icons.calendar_today_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                                        label: context.l10n('Date', 'Ngày'),
                                        value: booking.bookingDate,
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.bookingDetailRowModel2,
                                      updateCallback: () => safeSetState(() {}),
                                      child: BookingDetailRowWidget(
                                        icon: Icon(Icons.schedule_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                                        label: context.l10n('Time Slot', 'Khung giờ'),
                                        value: timeDisplay,
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.bookingDetailRowModel3,
                                      updateCallback: () => safeSetState(() {}),
                                      child: BookingDetailRowWidget(
                                        icon: Icon(Icons.confirmation_number_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                                        label: context.l10n('Booking ID', 'Mã đặt sân'),
                                        value: booking.id,
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 16.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                  child: Container(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.goNamed(HomeDashboardWidget.routeName);
                                },
                                child: wrapWithModel(
                                  model: _model.buttonModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ButtonWidget(
                                    content: context.l10n('Back to Home', 'Quay lại trang chủ'),
                                    iconPresent: false,
                                    iconEndPresent: false,
                                    variant: 'primary',
                                    size: 'large',
                                    fullWidth: true,
                                    loading: false,
                                    disabled: false,
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.goNamed(UserProfileWidget.routeName);
                                },
                                child: wrapWithModel(
                                  model: _model.buttonModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ButtonWidget(
                                    content: context.l10n('Manage My Bookings', 'Quản lý lịch đặt'),
                                    iconPresent: false,
                                    iconEndPresent: false,
                                    variant: 'ghost',
                                    size: 'medium',
                                    fullWidth: false,
                                    loading: false,
                                    disabled: false,
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
