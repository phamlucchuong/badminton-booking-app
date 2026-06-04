import '/components/booking_detail_row/booking_detail_row_widget.dart';
import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'booking_confirmation_widget.dart' show BookingConfirmationWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BookingConfirmationModel
    extends FlutterFlowModel<BookingConfirmationWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for BookingDetailRow.
  late BookingDetailRowModel bookingDetailRowModel1;
  // Model for BookingDetailRow.
  late BookingDetailRowModel bookingDetailRowModel2;
  // Model for BookingDetailRow.
  late BookingDetailRowModel bookingDetailRowModel3;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for Button.
  late ButtonModel buttonModel3;
  // Model for Button.
  late ButtonModel buttonModel4;

  @override
  void initState(BuildContext context) {
    bookingDetailRowModel1 =
        createModel(context, () => BookingDetailRowModel());
    bookingDetailRowModel2 =
        createModel(context, () => BookingDetailRowModel());
    bookingDetailRowModel3 =
        createModel(context, () => BookingDetailRowModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    buttonModel3 = createModel(context, () => ButtonModel());
    buttonModel4 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    bookingDetailRowModel1.dispose();
    bookingDetailRowModel2.dispose();
    bookingDetailRowModel3.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    buttonModel3.dispose();
    buttonModel4.dispose();
  }
}
