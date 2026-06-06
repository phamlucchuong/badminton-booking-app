import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'addon_row_model.dart';
export 'addon_row_model.dart';

class AddonRowWidget extends StatefulWidget {
  const AddonRowWidget({
    super.key,
    String? imgDesc,
    String? name,
    String? price,
    String? id,
    String? qty,
  })  : this.imgDesc = imgDesc ?? '',
        this.name = name ?? '',
        this.price = price ?? '\$\${item[\'price\']} / unit',
        this.id = id ?? '',
        this.qty = qty ?? '';

  final String imgDesc;
  final String name;
  final String price;
  final String id;
  final String qty;

  @override
  State<AddonRowWidget> createState() => _AddonRowWidgetState();
}

class _AddonRowWidgetState extends State<AddonRowWidget> {
  late AddonRowModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddonRowModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).surfaceVariant,
              borderRadius: BorderRadius.circular(10.0),
              shape: BoxShape.rectangle,
            ),
            child: CachedNetworkImage(
              fadeInDuration: Duration(milliseconds: 0),
              fadeOutDuration: Duration(milliseconds: 0),
              imageUrl: widget!.imgDesc,
              fit: BoxFit.cover,
              alignment: Alignment(0.0, 0.0),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.qty.isNotEmpty ? '${widget.name} (x${widget.qty})' : widget.name,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      lineHeight: 1.5,
                    ),
              ),
              Text(
                valueOrDefault<String>(
                  widget!.price,
                  '\$\${item[\'price\']} / unit',
                ),
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).labelSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).labelSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      lineHeight: 1.3,
                    ),
              ),
            ].divide(SizedBox(height: 4.0)),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: FlutterFlowTheme.of(context).error,
            size: 20.0,
          ),
          onPressed: () {
            final cartList = List<Map<String, dynamic>>.from(
              FFAppState().cartAddons.map((e) => Map<String, dynamic>.from(e as Map)),
            );
            final existingIndex = cartList.indexWhere(
              (element) => element['productId'] == widget.id,
            );

            if (existingIndex != -1) {
              final currentQty = cartList[existingIndex]['quantity'] as int? ?? 0;
              if (currentQty > 1) {
                cartList[existingIndex]['quantity'] = currentQty - 1;
              } else {
                cartList.removeAt(existingIndex);
              }
            }

            FFAppState().update(() {
              FFAppState().cartAddons = cartList;
            });
          },
        ),
      ].divide(SizedBox(width: 16.0)),
    );
  }
}
