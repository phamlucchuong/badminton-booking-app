import '/components/button/button_widget.dart';
import '/components/profile_menu_item/profile_menu_item_widget.dart';
import '/components/section_header/section_header_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel1;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel1;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel2;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel3;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel2;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel4;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel5;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel6;
  // Model for SectionHeader.
  late SectionHeaderModel sectionHeaderModel3;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel7;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel8;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    sectionHeaderModel1 = createModel(context, () => SectionHeaderModel());
    profileMenuItemModel1 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel2 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel3 = createModel(context, () => ProfileMenuItemModel());
    sectionHeaderModel2 = createModel(context, () => SectionHeaderModel());
    profileMenuItemModel4 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel5 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel6 = createModel(context, () => ProfileMenuItemModel());
    sectionHeaderModel3 = createModel(context, () => SectionHeaderModel());
    profileMenuItemModel7 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel8 = createModel(context, () => ProfileMenuItemModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    sectionHeaderModel1.dispose();
    profileMenuItemModel1.dispose();
    profileMenuItemModel2.dispose();
    profileMenuItemModel3.dispose();
    sectionHeaderModel2.dispose();
    profileMenuItemModel4.dispose();
    profileMenuItemModel5.dispose();
    profileMenuItemModel6.dispose();
    sectionHeaderModel3.dispose();
    profileMenuItemModel7.dispose();
    profileMenuItemModel8.dispose();
    buttonModel2.dispose();
  }
}
