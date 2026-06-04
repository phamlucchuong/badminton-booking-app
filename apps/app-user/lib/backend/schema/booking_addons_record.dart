import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BookingAddonsRecord extends FirestoreRecord {
  BookingAddonsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "bookingId" field.
  String? _bookingId;
  String get bookingId => _bookingId ?? '';
  bool hasBookingId() => _bookingId != null;

  // "addonId" field.
  String? _addonId;
  String get addonId => _addonId ?? '';
  bool hasAddonId() => _addonId != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  void _initializeFields() {
    _bookingId = snapshotData['bookingId'] as String?;
    _addonId = snapshotData['addonId'] as String?;
    _quantity = castToType<int>(snapshotData['quantity']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('booking_addons');

  static Stream<BookingAddonsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BookingAddonsRecord.fromSnapshot(s));

  static Future<BookingAddonsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BookingAddonsRecord.fromSnapshot(s));

  static BookingAddonsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BookingAddonsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BookingAddonsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BookingAddonsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BookingAddonsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BookingAddonsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBookingAddonsRecordData({
  String? bookingId,
  String? addonId,
  int? quantity,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'bookingId': bookingId,
      'addonId': addonId,
      'quantity': quantity,
    }.withoutNulls,
  );

  return firestoreData;
}

class BookingAddonsRecordDocumentEquality
    implements Equality<BookingAddonsRecord> {
  const BookingAddonsRecordDocumentEquality();

  @override
  bool equals(BookingAddonsRecord? e1, BookingAddonsRecord? e2) {
    return e1?.bookingId == e2?.bookingId &&
        e1?.addonId == e2?.addonId &&
        e1?.quantity == e2?.quantity;
  }

  @override
  int hash(BookingAddonsRecord? e) =>
      const ListEquality().hash([e?.bookingId, e?.addonId, e?.quantity]);

  @override
  bool isValidKey(Object? o) => o is BookingAddonsRecord;
}
