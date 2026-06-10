import '/components/button/button_widget.dart';
import '/components/equipment_item/equipment_item_widget.dart';
import '/components/review_item/review_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'court_details_widget.dart' show CourtDetailsWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CourtDetailsModel extends FlutterFlowModel<CourtDetailsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for EquipmentItem.
  late EquipmentItemModel equipmentItemModel1;
  // Model for EquipmentItem.
  late EquipmentItemModel equipmentItemModel2;
  // Model for EquipmentItem.
  late EquipmentItemModel equipmentItemModel3;
  // Model for EquipmentItem.
  late EquipmentItemModel equipmentItemModel4;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    equipmentItemModel1 = createModel(context, () => EquipmentItemModel());
    equipmentItemModel2 = createModel(context, () => EquipmentItemModel());
    equipmentItemModel3 = createModel(context, () => EquipmentItemModel());
    equipmentItemModel4 = createModel(context, () => EquipmentItemModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    equipmentItemModel1.dispose();
    equipmentItemModel2.dispose();
    equipmentItemModel3.dispose();
    equipmentItemModel4.dispose();
    buttonModel.dispose();
  }
}
