import '/components/button/button_widget.dart';
import '/components/payment_detail_item/payment_detail_item_widget.dart';
import '/components/step_indicator/step_indicator_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'q_r_payment_widget.dart' show QRPaymentWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QRPaymentModel extends FlutterFlowModel<QRPaymentWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel1;
  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel2;
  // Model for StepIndicator.
  late StepIndicatorModel stepIndicatorModel3;
  // Model for PaymentDetailItem.
  late PaymentDetailItemModel paymentDetailItemModel1;
  // Model for PaymentDetailItem.
  late PaymentDetailItemModel paymentDetailItemModel2;
  // Model for PaymentDetailItem.
  late PaymentDetailItemModel paymentDetailItemModel3;
  // Model for PaymentDetailItem.
  late PaymentDetailItemModel paymentDetailItemModel4;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    stepIndicatorModel1 = createModel(context, () => StepIndicatorModel());
    stepIndicatorModel2 = createModel(context, () => StepIndicatorModel());
    stepIndicatorModel3 = createModel(context, () => StepIndicatorModel());
    paymentDetailItemModel1 =
        createModel(context, () => PaymentDetailItemModel());
    paymentDetailItemModel2 =
        createModel(context, () => PaymentDetailItemModel());
    paymentDetailItemModel3 =
        createModel(context, () => PaymentDetailItemModel());
    paymentDetailItemModel4 =
        createModel(context, () => PaymentDetailItemModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    stepIndicatorModel1.dispose();
    stepIndicatorModel2.dispose();
    stepIndicatorModel3.dispose();
    paymentDetailItemModel1.dispose();
    paymentDetailItemModel2.dispose();
    paymentDetailItemModel3.dispose();
    paymentDetailItemModel4.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
