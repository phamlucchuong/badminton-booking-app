import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

extension TranslationExtension on BuildContext {
  String l10n(String en, String vi) {
    try {
      final language = Provider.of<FFAppState>(this, listen: true).language;
      return language == 'VI' ? vi : en;
    } catch (_) {
      return en;
    }
  }

  String translate(String key) {
    try {
      final language = Provider.of<FFAppState>(this, listen: true).language;
      final translation = _translations[key];
      if (translation == null) return key;
      return language == 'VI' ? (translation['VI'] ?? key) : (translation['EN'] ?? key);
    } catch (_) {
      return key;
    }
  }
}

final Map<String, Map<String, String>> _translations = {
  'search_venue': {
    'EN': 'Search court...',
    'VI': 'Tìm kiếm sân...',
  },
  'location': {
    'EN': 'Location',
    'VI': 'Vị trí',
  },
  'price': {
    'EN': 'Price',
    'VI': 'Giá',
  },
  'rating': {
    'EN': 'Rating',
    'VI': 'Đánh giá',
  },
  'booking_confirmed': {
    'EN': 'Booking Confirmed!',
    'VI': 'Đặt sân thành công!',
  },
  'ready_for_action': {
    'EN': 'Your court is ready for action',
    'VI': 'Sân của bạn đã sẵn sàng',
  },
  'back_to_home': {
    'EN': 'Back to Home',
    'VI': 'Quay lại trang chủ',
  },
  'manage_bookings': {
    'EN': 'Manage My Bookings',
    'VI': 'Quản lý lịch đặt',
  },
  'date': {
    'EN': 'Date',
    'VI': 'Ngày',
  },
  'time_slot': {
    'EN': 'Time Slot',
    'VI': 'Khung giờ',
  },
  'booking_id': {
    'EN': 'Booking ID',
    'VI': 'Mã đặt sân',
  },
};
