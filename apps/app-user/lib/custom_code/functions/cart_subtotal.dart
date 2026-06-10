import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';

double cartSubtotal(List<dynamic> cartAddons) {
  double total = 0.0;
  for (final item in cartAddons) {
    if (item is Map) {
      final priceVal = item['price'];
      final quantityVal = item['quantity'];
      if (priceVal != null && quantityVal != null) {
        final price = double.tryParse(priceVal.toString()) ?? 0.0;
        final quantity = int.tryParse(quantityVal.toString()) ?? 0;
        total += price * quantity;
      }
    }
  }
  return total;
}
