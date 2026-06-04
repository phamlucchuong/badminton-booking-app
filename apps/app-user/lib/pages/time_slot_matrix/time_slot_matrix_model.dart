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
import 'time_slot_matrix_widget.dart' show TimeSlotMatrixWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TimeSlotMatrixModel extends FlutterFlowModel<TimeSlotMatrixWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel1;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel2;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel3;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel4;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel5;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel6;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel7;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel8;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel9;
  // Model for CourtHeader.
  late CourtHeaderModel courtHeaderModel10;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel1;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel2;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel3;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel4;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel5;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel6;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel7;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel8;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel9;
  // Model for TimeHeader.
  late TimeHeaderModel timeHeaderModel10;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel1;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel2;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel3;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel4;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel5;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel6;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel7;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel8;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel9;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel10;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel11;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel12;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel13;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel14;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel15;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel16;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel17;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel18;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel19;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel20;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel21;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel22;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel23;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel24;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel25;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel26;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel27;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel28;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel29;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel30;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel31;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel32;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel33;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel34;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel35;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel36;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel37;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel38;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel39;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel40;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel41;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel42;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel43;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel44;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel45;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel46;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel47;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel48;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel49;
  // Model for GridSlot.
  late GridSlotModel gridSlotModel50;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    courtHeaderModel1 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel2 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel3 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel4 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel5 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel6 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel7 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel8 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel9 = createModel(context, () => CourtHeaderModel());
    courtHeaderModel10 = createModel(context, () => CourtHeaderModel());
    timeHeaderModel1 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel2 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel3 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel4 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel5 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel6 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel7 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel8 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel9 = createModel(context, () => TimeHeaderModel());
    timeHeaderModel10 = createModel(context, () => TimeHeaderModel());
    gridSlotModel1 = createModel(context, () => GridSlotModel());
    gridSlotModel2 = createModel(context, () => GridSlotModel());
    gridSlotModel3 = createModel(context, () => GridSlotModel());
    gridSlotModel4 = createModel(context, () => GridSlotModel());
    gridSlotModel5 = createModel(context, () => GridSlotModel());
    gridSlotModel6 = createModel(context, () => GridSlotModel());
    gridSlotModel7 = createModel(context, () => GridSlotModel());
    gridSlotModel8 = createModel(context, () => GridSlotModel());
    gridSlotModel9 = createModel(context, () => GridSlotModel());
    gridSlotModel10 = createModel(context, () => GridSlotModel());
    gridSlotModel11 = createModel(context, () => GridSlotModel());
    gridSlotModel12 = createModel(context, () => GridSlotModel());
    gridSlotModel13 = createModel(context, () => GridSlotModel());
    gridSlotModel14 = createModel(context, () => GridSlotModel());
    gridSlotModel15 = createModel(context, () => GridSlotModel());
    gridSlotModel16 = createModel(context, () => GridSlotModel());
    gridSlotModel17 = createModel(context, () => GridSlotModel());
    gridSlotModel18 = createModel(context, () => GridSlotModel());
    gridSlotModel19 = createModel(context, () => GridSlotModel());
    gridSlotModel20 = createModel(context, () => GridSlotModel());
    gridSlotModel21 = createModel(context, () => GridSlotModel());
    gridSlotModel22 = createModel(context, () => GridSlotModel());
    gridSlotModel23 = createModel(context, () => GridSlotModel());
    gridSlotModel24 = createModel(context, () => GridSlotModel());
    gridSlotModel25 = createModel(context, () => GridSlotModel());
    gridSlotModel26 = createModel(context, () => GridSlotModel());
    gridSlotModel27 = createModel(context, () => GridSlotModel());
    gridSlotModel28 = createModel(context, () => GridSlotModel());
    gridSlotModel29 = createModel(context, () => GridSlotModel());
    gridSlotModel30 = createModel(context, () => GridSlotModel());
    gridSlotModel31 = createModel(context, () => GridSlotModel());
    gridSlotModel32 = createModel(context, () => GridSlotModel());
    gridSlotModel33 = createModel(context, () => GridSlotModel());
    gridSlotModel34 = createModel(context, () => GridSlotModel());
    gridSlotModel35 = createModel(context, () => GridSlotModel());
    gridSlotModel36 = createModel(context, () => GridSlotModel());
    gridSlotModel37 = createModel(context, () => GridSlotModel());
    gridSlotModel38 = createModel(context, () => GridSlotModel());
    gridSlotModel39 = createModel(context, () => GridSlotModel());
    gridSlotModel40 = createModel(context, () => GridSlotModel());
    gridSlotModel41 = createModel(context, () => GridSlotModel());
    gridSlotModel42 = createModel(context, () => GridSlotModel());
    gridSlotModel43 = createModel(context, () => GridSlotModel());
    gridSlotModel44 = createModel(context, () => GridSlotModel());
    gridSlotModel45 = createModel(context, () => GridSlotModel());
    gridSlotModel46 = createModel(context, () => GridSlotModel());
    gridSlotModel47 = createModel(context, () => GridSlotModel());
    gridSlotModel48 = createModel(context, () => GridSlotModel());
    gridSlotModel49 = createModel(context, () => GridSlotModel());
    gridSlotModel50 = createModel(context, () => GridSlotModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    courtHeaderModel1.dispose();
    courtHeaderModel2.dispose();
    courtHeaderModel3.dispose();
    courtHeaderModel4.dispose();
    courtHeaderModel5.dispose();
    courtHeaderModel6.dispose();
    courtHeaderModel7.dispose();
    courtHeaderModel8.dispose();
    courtHeaderModel9.dispose();
    courtHeaderModel10.dispose();
    timeHeaderModel1.dispose();
    timeHeaderModel2.dispose();
    timeHeaderModel3.dispose();
    timeHeaderModel4.dispose();
    timeHeaderModel5.dispose();
    timeHeaderModel6.dispose();
    timeHeaderModel7.dispose();
    timeHeaderModel8.dispose();
    timeHeaderModel9.dispose();
    timeHeaderModel10.dispose();
    gridSlotModel1.dispose();
    gridSlotModel2.dispose();
    gridSlotModel3.dispose();
    gridSlotModel4.dispose();
    gridSlotModel5.dispose();
    gridSlotModel6.dispose();
    gridSlotModel7.dispose();
    gridSlotModel8.dispose();
    gridSlotModel9.dispose();
    gridSlotModel10.dispose();
    gridSlotModel11.dispose();
    gridSlotModel12.dispose();
    gridSlotModel13.dispose();
    gridSlotModel14.dispose();
    gridSlotModel15.dispose();
    gridSlotModel16.dispose();
    gridSlotModel17.dispose();
    gridSlotModel18.dispose();
    gridSlotModel19.dispose();
    gridSlotModel20.dispose();
    gridSlotModel21.dispose();
    gridSlotModel22.dispose();
    gridSlotModel23.dispose();
    gridSlotModel24.dispose();
    gridSlotModel25.dispose();
    gridSlotModel26.dispose();
    gridSlotModel27.dispose();
    gridSlotModel28.dispose();
    gridSlotModel29.dispose();
    gridSlotModel30.dispose();
    gridSlotModel31.dispose();
    gridSlotModel32.dispose();
    gridSlotModel33.dispose();
    gridSlotModel34.dispose();
    gridSlotModel35.dispose();
    gridSlotModel36.dispose();
    gridSlotModel37.dispose();
    gridSlotModel38.dispose();
    gridSlotModel39.dispose();
    gridSlotModel40.dispose();
    gridSlotModel41.dispose();
    gridSlotModel42.dispose();
    gridSlotModel43.dispose();
    gridSlotModel44.dispose();
    gridSlotModel45.dispose();
    gridSlotModel46.dispose();
    gridSlotModel47.dispose();
    gridSlotModel48.dispose();
    gridSlotModel49.dispose();
    gridSlotModel50.dispose();
    buttonModel.dispose();
  }
}
