import '/components/addon_row/addon_row_widget.dart';
import '/components/button/button_widget.dart';
import '/components/summary_item/summary_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/models/booking.dart';
import '/models/venue.dart';
import '/models/court.dart';
import 'package:intl/intl.dart';
import '/services/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'review_order_model.dart';

export 'review_order_model.dart';

class ReviewOrderWidget extends StatefulWidget {
  const ReviewOrderWidget({super.key});

  static String routeName = 'ReviewOrder';
  static String routePath = '/reviewOrder';

  @override
  State<ReviewOrderWidget> createState() => _ReviewOrderWidgetState();
}

class _ReviewOrderWidgetState extends State<ReviewOrderWidget> {
  late ReviewOrderModel _model;
  late Future<Map<String, dynamic>> _dataFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewOrderModel());
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final venueId = FFAppState().currentVenueId;
    final venue = await FFAppState().venueRepository.getVenue(venueId);
    final courts = await FFAppState().venueRepository.getCourts(venueId);
    return {
      'venue': venue,
      'courts': courts,
    };
  }

  String formatBookingDate(BuildContext context, String dateStr) {
    if (dateStr.isEmpty) {
      dateStr = DateTime.now().toIso8601String().split('T').first;
    }
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final isVi = FFAppState().language.toUpperCase() == 'VI';
    return DateFormat(isVi ? 'dd/MM/yyyy' : 'EEE, MMM d, yyyy').format(dt);
  }

  String formatTimeSlots(BuildContext context, List<dynamic> selectedSlots) {
    if (selectedSlots.isEmpty)
      return context.l10n('No slots', 'Chưa chọn ô giờ');
    final sorted = List<Map<String, dynamic>>.from(
        selectedSlots.whereType<Map<String, dynamic>>());
    sorted.sort((a, b) =>
        (a['startTime'] as String).compareTo(b['startTime'] as String));
    final start = sorted.first['startTime'] as String;
    final end = sorted.last['endTime'] as String;
    final startFormatted = start.substring(0, 5);
    final endFormatted = end.substring(0, 5);
    return '$startFormatted - $endFormatted';
  }

  String formatSlotsSubtitle(
      BuildContext context, List<dynamic> selectedSlots) {
    final count = selectedSlots.length;
    final durationMin = count * 60;
    return context.l10n(
      '$count Slot${count > 1 ? "s" : ""} ($durationMin min total)',
      '$count ô giờ (tổng $durationMin phút)',
    );
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(context.l10n('Error loading booking details: ',
                        'Lỗi tải thông tin chi tiết đặt sân: ') +
                    snapshot.error.toString()),
              );
            }
            final data = snapshot.data!;
            final venue = data['venue'] as Venue;
            final courts = data['courts'] as List<Court>;

            final selectedSlots = FFAppState().selectedSlots.toList();
            final cartAddons = FFAppState().cartAddons.toList();

            double slotsPrice = 0.0;
            for (final slot in selectedSlots) {
              if (slot is Map) {
                final priceVal = slot['price'];
                slotsPrice += double.tryParse(priceVal.toString()) ?? 20.0;
              } else {
                slotsPrice += 20.0;
              }
            }

            final addonsPrice = functions.cartSubtotal(cartAddons);
            final totalPrice = slotsPrice + addonsPrice;

            final slotsPriceFormatted =
                '${slotsPrice.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
            final addonsPriceFormatted =
                '${addonsPrice.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
            final totalPriceFormatted =
                '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';

            final selectedCourtIds =
                selectedSlots.map((s) => s['courtId']).toSet();
            final selectedCourtNames = courts
                .where((c) => selectedCourtIds.contains(c.id))
                .map((c) => c.name)
                .join(', ');

            final bookingDateStr =
                formatBookingDate(context, FFAppState().currentBookingDate);
            final timeSlotsStr = formatTimeSlots(context, selectedSlots);
            final slotsSubtitleStr =
                formatSlotsSubtitle(context, selectedSlots);

            return SafeArea(
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 16.0, 24.0, 16.0),
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
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    context.pop();
                                  },
                                ),
                                Text(
                                  context.l10n(
                                      'Review Order', 'Xác nhận đơn hàng'),
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Container(
                                  width: 40.0,
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
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 44.0,
                                                  height: 44.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary10,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Icon(
                                                    Icons.sports_tennis_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 24.0,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      selectedCourtNames
                                                              .isNotEmpty
                                                          ? selectedCourtNames
                                                          : context.l10n(
                                                              'Court Detail',
                                                              'Chi tiết sân'),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .plusJakartaSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                            lineHeight: 1.4,
                                                          ),
                                                    ),
                                                    Text(
                                                      venue.name,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                                lineHeight: 1.5,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ].divide(SizedBox(width: 16.0)),
                                            ),
                                            Divider(
                                              height: 16.0,
                                              thickness: 1.0,
                                              indent: 0.0,
                                              endIndent: 0.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            wrapWithModel(
                                              model: _model.summaryItemModel1,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: SummaryItemWidget(
                                                label: context.l10n(
                                                    'Date', 'Ngày'),
                                                subtitle: '',
                                                hasSubtitle: false,
                                                value: bookingDateStr,
                                              ),
                                            ),
                                            wrapWithModel(
                                              model: _model.summaryItemModel2,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: SummaryItemWidget(
                                                label: context.l10n(
                                                    'Time Slots', 'Khung giờ'),
                                                subtitle: slotsSubtitleStr,
                                                hasSubtitle: true,
                                                value: timeSlotsStr,
                                              ),
                                            ),
                                            wrapWithModel(
                                              model: _model.summaryItemModel3,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: SummaryItemWidget(
                                                label: context.l10n(
                                                    'Court Fee', 'Tiền sân'),
                                                subtitle: '',
                                                hasSubtitle: false,
                                                value: slotsPriceFormatted,
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 16.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            context.l10n('Rental & Add-ons',
                                                'Dịch vụ & Tiện ích'),
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                          Text(
                                            context.l10n(
                                                'Add more', 'Thêm dịch vụ'),
                                            style: FlutterFlowTheme.of(context)
                                                .labelLarge
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelLarge
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: cartAddons.isEmpty
                                              ? Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0),
                                                    child: Text(
                                                      context.l10n(
                                                          'No rental & add-ons selected',
                                                          'Chưa chọn dịch vụ & tiện ích'),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .inter(),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                              ),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: cartAddons
                                                      .map((item) {
                                                        if (item is! Map)
                                                          return Container();
                                                        final name = item[
                                                                    'name']
                                                                ?.toString() ??
                                                            '';
                                                        final priceVal = double
                                                                .tryParse(item[
                                                                            'price']
                                                                        ?.toString() ??
                                                                    '0') ??
                                                            0.0;
                                                        final priceFormatted =
                                                            '${priceVal.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ / unit';
                                                        final qty = item[
                                                                    'quantity']
                                                                ?.toString() ??
                                                            '0';
                                                        final img = item[
                                                                    'imageId']
                                                                ?.toString() ??
                                                            '';
                                                        return AddonRowWidget(
                                                          key: ValueKey(item[
                                                              'productId']),
                                                          imgDesc: img
                                                                  .startsWith(
                                                                      'http')
                                                              ? img
                                                              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
                                                          name: name,
                                                          price: priceFormatted,
                                                          id: item['productId']
                                                                  ?.toString() ??
                                                              '',
                                                          qty: qty,
                                                        );
                                                      })
                                                      .toList()
                                                      .divide(SizedBox(
                                                          height: 16.0)),
                                                ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 16.0)),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        context.l10n('Payment Summary',
                                            'Tóm tắt thanh toán'),
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(24.0),
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                wrapWithModel(
                                                  model:
                                                      _model.summaryItemModel4,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: SummaryItemWidget(
                                                    label: context.l10n(
                                                        'Subtotal', 'Tạm tính'),
                                                    subtitle: '',
                                                    hasSubtitle: false,
                                                    value: addonsPriceFormatted,
                                                  ),
                                                ),
                                                wrapWithModel(
                                                  model:
                                                      _model.summaryItemModel5,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: SummaryItemWidget(
                                                    label: context.l10n(
                                                        'Service Fee (5%)',
                                                        'Phí dịch vụ (5%)'),
                                                    subtitle: '',
                                                    hasSubtitle: false,
                                                    value: '0đ',
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 16.0, 0.0, 16.0),
                                                  child: Container(
                                                    child: Divider(
                                                      height: 16.0,
                                                      thickness: 1.0,
                                                      indent: 0.0,
                                                      endIndent: 0.0,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      context.l10n(
                                                          'Total Amount',
                                                          'Tổng số tiền'),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .plusJakartaSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                            lineHeight: 1.4,
                                                          ),
                                                    ),
                                                    Text(
                                                      totalPriceFormatted,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 8.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 16.0)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).info10,
                                      borderRadius: BorderRadius.circular(10.0),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color:
                                            FlutterFlowTheme.of(context).info20,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              size: 20.0,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                context.l10n(
                                                    'Cancellations made 24h before the slot are eligible for a 50% refund to wallet.',
                                                    'Hủy sân trước 24 giờ sẽ được hoàn lại 50% vào ví của bạn.'),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                      lineHeight: 1.5,
                                                    ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.l10n('Total to pay',
                                              'Tổng thanh toán'),
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                        Text(
                                          totalPriceFormatted,
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleLarge
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge
                                                        .fontStyle,
                                                lineHeight: 1.3,
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
                                        final slots = FFAppState()
                                            .selectedSlots
                                            .whereType<Map<String, dynamic>>()
                                            .toList();
                                        if (slots.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(context.l10n(
                                                      'No slots selected',
                                                      'Chưa chọn khung giờ nào'))));
                                          return;
                                        }
                                        final sortedSlots =
                                            List<Map<String, dynamic>>.from(
                                                slots);
                                        sortedSlots.sort((a, b) =>
                                            (a['startTime'] as String)
                                                .compareTo(
                                                    b['startTime'] as String));

                                        final addons = FFAppState()
                                            .cartAddons
                                            .whereType<Map<String, dynamic>>()
                                            .toList();
                                        final today = FFAppState()
                                                .currentBookingDate
                                                .isNotEmpty
                                            ? FFAppState().currentBookingDate
                                            : DateTime.now()
                                                .toIso8601String()
                                                .split('T')
                                                .first;
                                        final request = BookingCreateRequest(
                                          courtId: sortedSlots.first['courtId']
                                              as String,
                                          venueId: FFAppState().currentVenueId,
                                          bookingDate: today,
                                          startTime: sortedSlots
                                              .first['startTime'] as String,
                                          endTime: sortedSlots.last['endTime']
                                              as String,
                                          type: 'HOURLY',
                                          paymentMethod: 'CASH',
                                          products: addons
                                              .map((a) => BookingProductLine(
                                                    productId: a['productId']
                                                        as String,
                                                    quantity:
                                                        (a['quantity'] as num)
                                                            .toInt(),
                                                  ))
                                              .toList(),
                                        );
                                        try {
                                          final booking = await FFAppState()
                                              .bookingRepository
                                              .createBooking(request);
                                          FFAppState().update(() {
                                            FFAppState().currentBookingId =
                                                booking.id;
                                            FFAppState().currentBooking =
                                                booking;
                                          });
                                          if (context.mounted) {
                                            context.goNamed(
                                                QRPaymentWidget.routeName);
                                          }
                                        } on ApiException catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(e.message)));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(context.l10n(
                                                        'Network error. Please try again.',
                                                        'Lỗi kết nối. Vui lòng thử lại.'))));
                                          }
                                        }
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonWidget(
                                          content: context.l10n(
                                              'Proceed to Payment',
                                              'Tiếp tục thanh toán'),
                                          icon: Icon(
                                            Icons.arrow_forward_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onPrimary,
                                            size: 16.0,
                                          ),
                                          iconPresent: true,
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
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
