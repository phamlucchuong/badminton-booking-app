import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'services/api_client.dart';
import 'services/token_store.dart';
import 'repositories/auth_repository.dart';
import 'repositories/venue_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/review_repository.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // --- Backend services (added during backend integration) ---
  final TokenStore tokenStore = TokenStore();
  late final ApiClient apiClient =
      ApiClient(tokenProvider: tokenStore.read);
  late final AuthRepository authRepository =
      AuthRepository(apiClient, tokenStore);
  late final VenueRepository venueRepository = VenueRepository(apiClient);
  late final BookingRepository bookingRepository = BookingRepository(apiClient);
  late final PaymentRepository paymentRepository = PaymentRepository(apiClient);
  late final ReviewRepository reviewRepository = ReviewRepository(apiClient);

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) => _isLoggedIn = value;

  // Transient booking-flow state — set in time_slot_matrix, consumed in review_order / payment.
  String currentVenueId = '';
  String currentBookingId = '';
  String currentBookingDate = '';

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
  }

  String _filterCategory = 'All';
  String get filterCategory => _filterCategory;
  set filterCategory(String value) {
    _filterCategory = value;
  }

  bool _darkMode = false;
  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    _darkMode = value;
  }

  String _language = 'EN';
  String get language => _language;
  set language(String value) {
    _language = value;
  }

  List<dynamic> _cartAddons = [jsonDecode('[]')];
  List<dynamic> get cartAddons => _cartAddons;
  set cartAddons(List<dynamic> value) {
    _cartAddons = value;
  }

  void addToCartAddons(dynamic value) {
    cartAddons.add(value);
  }

  void removeFromCartAddons(dynamic value) {
    cartAddons.remove(value);
  }

  void removeAtIndexFromCartAddons(int index) {
    cartAddons.removeAt(index);
  }

  void updateCartAddonsAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    cartAddons[index] = updateFn(_cartAddons[index]);
  }

  void insertAtIndexInCartAddons(int index, dynamic value) {
    cartAddons.insert(index, value);
  }

  List<dynamic> _selectedSlots = [jsonDecode('[]')];
  List<dynamic> get selectedSlots => _selectedSlots;
  set selectedSlots(List<dynamic> value) {
    _selectedSlots = value;
  }

  void addToSelectedSlots(dynamic value) {
    selectedSlots.add(value);
  }

  void removeFromSelectedSlots(dynamic value) {
    selectedSlots.remove(value);
  }

  void removeAtIndexFromSelectedSlots(int index) {
    selectedSlots.removeAt(index);
  }

  void updateSelectedSlotsAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    selectedSlots[index] = updateFn(_selectedSlots[index]);
  }

  void insertAtIndexInSelectedSlots(int index, dynamic value) {
    selectedSlots.insert(index, value);
  }
}
