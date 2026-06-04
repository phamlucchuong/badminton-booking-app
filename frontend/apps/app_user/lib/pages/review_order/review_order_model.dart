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
import 'review_order_widget.dart' show ReviewOrderWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReviewOrderModel extends FlutterFlowModel<ReviewOrderWidget> {
  ///  Local state fields for this page.

  double? serviceFeePercent = 0.05;

  ///  State fields for stateful widgets in this page.

  // Model for SummaryItem.
  late SummaryItemModel summaryItemModel1;
  // Model for SummaryItem.
  late SummaryItemModel summaryItemModel2;
  // Model for SummaryItem.
  late SummaryItemModel summaryItemModel3;
  // Model for AddonRow.
  late AddonRowModel addonRowModel;
  // Model for SummaryItem.
  late SummaryItemModel summaryItemModel4;
  // Model for SummaryItem.
  late SummaryItemModel summaryItemModel5;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    summaryItemModel1 = createModel(context, () => SummaryItemModel());
    summaryItemModel2 = createModel(context, () => SummaryItemModel());
    summaryItemModel3 = createModel(context, () => SummaryItemModel());
    addonRowModel = createModel(context, () => AddonRowModel());
    summaryItemModel4 = createModel(context, () => SummaryItemModel());
    summaryItemModel5 = createModel(context, () => SummaryItemModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    summaryItemModel1.dispose();
    summaryItemModel2.dispose();
    summaryItemModel3.dispose();
    addonRowModel.dispose();
    summaryItemModel4.dispose();
    summaryItemModel5.dispose();
    buttonModel.dispose();
  }
}
