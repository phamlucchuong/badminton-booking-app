import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TimeSlotsRecord extends FirestoreRecord {
  TimeSlotsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "bookingId" field.
  String? _bookingId;
  String get bookingId => _bookingId ?? '';
  bool hasBookingId() => _bookingId != null;

  // "courtName" field.
  String? _courtName;
  String get courtName => _courtName ?? '';
  bool hasCourtName() => _courtName != null;

  // "startTime" field.
  String? _startTime;
  String get startTime => _startTime ?? '';
  bool hasStartTime() => _startTime != null;

  // "endTime" field.
  String? _endTime;
  String get endTime => _endTime ?? '';
  bool hasEndTime() => _endTime != null;

  void _initializeFields() {
    _bookingId = snapshotData['bookingId'] as String?;
    _courtName = snapshotData['courtName'] as String?;
    _startTime = snapshotData['startTime'] as String?;
    _endTime = snapshotData['endTime'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('time_slots');

  static Stream<TimeSlotsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TimeSlotsRecord.fromSnapshot(s));

  static Future<TimeSlotsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TimeSlotsRecord.fromSnapshot(s));

  static TimeSlotsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TimeSlotsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TimeSlotsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TimeSlotsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TimeSlotsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TimeSlotsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTimeSlotsRecordData({
  String? bookingId,
  String? courtName,
  String? startTime,
  String? endTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'bookingId': bookingId,
      'courtName': courtName,
      'startTime': startTime,
      'endTime': endTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class TimeSlotsRecordDocumentEquality implements Equality<TimeSlotsRecord> {
  const TimeSlotsRecordDocumentEquality();

  @override
  bool equals(TimeSlotsRecord? e1, TimeSlotsRecord? e2) {
    return e1?.bookingId == e2?.bookingId &&
        e1?.courtName == e2?.courtName &&
        e1?.startTime == e2?.startTime &&
        e1?.endTime == e2?.endTime;
  }

  @override
  int hash(TimeSlotsRecord? e) => const ListEquality()
      .hash([e?.bookingId, e?.courtName, e?.startTime, e?.endTime]);

  @override
  bool isValidKey(Object? o) => o is TimeSlotsRecord;
}
