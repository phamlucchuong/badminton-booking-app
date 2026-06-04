import '/backend/backend.dart';
import '/components/court_card/court_card_widget.dart';
import '/components/promo_banner/promo_banner_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'home_dashboard_widget.dart' show HomeDashboardWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeDashboardModel extends FlutterFlowModel<HomeDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for PromoBanner.
  late PromoBannerModel promoBannerModel1;
  // Model for PromoBanner.
  late PromoBannerModel promoBannerModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel;

  @override
  void initState(BuildContext context) {
    promoBannerModel1 = createModel(context, () => PromoBannerModel());
    promoBannerModel2 = createModel(context, () => PromoBannerModel());
    textFieldModel = createModel(context, () => TextFieldModel());
  }

  @override
  void dispose() {
    promoBannerModel1.dispose();
    promoBannerModel2.dispose();
    textFieldModel.dispose();
  }
}
