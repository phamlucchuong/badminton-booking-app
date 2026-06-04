import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BookingsRecord extends FirestoreRecord {
  BookingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "courtId" field.
  String? _courtId;
  String get courtId => _courtId ?? '';
  bool hasCourtId() => _courtId != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "date" field.
  String? _date;
  String get date => _date ?? '';
  bool hasDate() => _date != null;

  // "totalPrice" field.
  double? _totalPrice;
  double get totalPrice => _totalPrice ?? 0.0;
  bool hasTotalPrice() => _totalPrice != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "bookingIdString" field.
  String? _bookingIdString;
  String get bookingIdString => _bookingIdString ?? '';
  bool hasBookingIdString() => _bookingIdString != null;

  void _initializeFields() {
    _courtId = snapshotData['courtId'] as String?;
    _userId = snapshotData['userId'] as String?;
    _date = snapshotData['date'] as String?;
    _totalPrice = castToType<double>(snapshotData['totalPrice']);
    _status = snapshotData['status'] as String?;
    _bookingIdString = snapshotData['bookingIdString'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('bookings');

  static Stream<BookingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BookingsRecord.fromSnapshot(s));

  static Future<BookingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BookingsRecord.fromSnapshot(s));

  static BookingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BookingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BookingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BookingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BookingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BookingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBookingsRecordData({
  String? courtId,
  String? userId,
  String? date,
  double? totalPrice,
  String? status,
  String? bookingIdString,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'courtId': courtId,
      'userId': userId,
      'date': date,
      'totalPrice': totalPrice,
      'status': status,
      'bookingIdString': bookingIdString,
    }.withoutNulls,
  );

  return firestoreData;
}

class BookingsRecordDocumentEquality implements Equality<BookingsRecord> {
  const BookingsRecordDocumentEquality();

  @override
  bool equals(BookingsRecord? e1, BookingsRecord? e2) {
    return e1?.courtId == e2?.courtId &&
        e1?.userId == e2?.userId &&
        e1?.date == e2?.date &&
        e1?.totalPrice == e2?.totalPrice &&
        e1?.status == e2?.status &&
        e1?.bookingIdString == e2?.bookingIdString;
  }

  @override
  int hash(BookingsRecord? e) => const ListEquality().hash([
        e?.courtId,
        e?.userId,
        e?.date,
        e?.totalPrice,
        e?.status,
        e?.bookingIdString
      ]);

  @override
  bool isValidKey(Object? o) => o is BookingsRecord;
}
