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

double bookingTotalPrice(
  List<dynamic> cartAddons,
  List<dynamic> selectedSlots,
) {
  double slotsPrice = 0.0;
  for (final slot in selectedSlots) {
    if (slot is Map) {
      final priceVal = slot['price'];
      if (priceVal != null) {
        slotsPrice += double.tryParse(priceVal.toString()) ?? 20.0;
      } else {
        slotsPrice += 20.0;
      }
    } else {
      slotsPrice += 20.0;
    }
  }
  return slotsPrice + cartSubtotal(cartAddons);
}
