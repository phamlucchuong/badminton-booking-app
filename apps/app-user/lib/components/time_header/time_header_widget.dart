import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'time_header_model.dart';
export 'time_header_model.dart';

class TimeHeaderWidget extends StatefulWidget {
  const TimeHeaderWidget({
    super.key,
    String? time,
  }) : this.time = time ?? '08:00';

  final String time;

  @override
  State<TimeHeaderWidget> createState() => _TimeHeaderWidgetState();
}

class _TimeHeaderWidgetState extends State<TimeHeaderWidget> {
  late TimeHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeHeaderModel());
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
      height: 40.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: BoxShape.rectangle,
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        valueOrDefault<String>(
          widget!.time,
          '08:00',
        ),
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
              lineHeight: 1.3,
            ),
      ),
    );
  }
}
