import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'grid_slot_model.dart';
export 'grid_slot_model.dart';

class GridSlotWidget extends StatefulWidget {
  const GridSlotWidget({
    super.key,
    String? state,
  }) : this.state = state ?? 'available';

  final String state;

  @override
  State<GridSlotWidget> createState() => _GridSlotWidgetState();
}

class _GridSlotWidgetState extends State<GridSlotWidget> {
  late GridSlotModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GridSlotModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: () {
          if (widget!.state == 'selected') {
            return FlutterFlowTheme.of(context).primary;
          } else if (widget!.state == 'unavailable') {
            return FlutterFlowTheme.of(context).surfaceVariant;
          } else {
            return FlutterFlowTheme.of(context).secondaryBackground;
          }
        }(),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 0.5,
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        () {
          if (widget!.state == 'selected') {
            return 'Booked';
          } else if (widget!.state == 'unavailable') {
            return 'Busy';
          } else {
            return 'Free';
          }
        }(),
        style: FlutterFlowTheme.of(context).labelSmall.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
              ),
              color: () {
                if (widget!.state == 'selected') {
                  return FlutterFlowTheme.of(context).onPrimary;
                } else if (widget!.state == 'unavailable') {
                  return FlutterFlowTheme.of(context).accent3;
                } else {
                  return FlutterFlowTheme.of(context).success;
                }
              }(),
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
              lineHeight: 1.3,
            ),
      ),
    );
  }
}
