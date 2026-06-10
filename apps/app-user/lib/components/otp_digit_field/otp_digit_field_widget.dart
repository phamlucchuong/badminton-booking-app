import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'otp_digit_field_model.dart';
export 'otp_digit_field_model.dart';

class OtpDigitFieldWidget extends StatefulWidget {
  const OtpDigitFieldWidget({
    super.key,
    String? value,
  }) : this.value = value ?? '';

  final String value;

  @override
  State<OtpDigitFieldWidget> createState() => _OtpDigitFieldWidgetState();
}

class _OtpDigitFieldWidgetState extends State<OtpDigitFieldWidget> {
  late OtpDigitFieldModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtpDigitFieldModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        widget!.value,
        style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
              fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
              lineHeight: 1.3,
            ),
      ),
    );
  }
}
