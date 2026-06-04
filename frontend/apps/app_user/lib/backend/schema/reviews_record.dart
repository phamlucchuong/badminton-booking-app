import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReviewsRecord extends FirestoreRecord {
  ReviewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "courtId" field.
  String? _courtId;
  String get courtId => _courtId ?? '';
  bool hasCourtId() => _courtId != null;

  // "userName" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "initials" field.
  String? _initials;
  String get initials => _initials ?? '';
  bool hasInitials() => _initials != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "date" field.
  String? _date;
  String get date => _date ?? '';
  bool hasDate() => _date != null;

  void _initializeFields() {
    _courtId = snapshotData['courtId'] as String?;
    _userName = snapshotData['userName'] as String?;
    _initials = snapshotData['initials'] as String?;
    _rating = castToType<double>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _date = snapshotData['date'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('reviews');

  static Stream<ReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReviewsRecord.fromSnapshot(s));

  static Future<ReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReviewsRecord.fromSnapshot(s));

  static ReviewsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReviewsRecordData({
  String? courtId,
  String? userName,
  String? initials,
  double? rating,
  String? comment,
  String? date,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'courtId': courtId,
      'userName': userName,
      'initials': initials,
      'rating': rating,
      'comment': comment,
      'date': date,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReviewsRecordDocumentEquality implements Equality<ReviewsRecord> {
  const ReviewsRecordDocumentEquality();

  @override
  bool equals(ReviewsRecord? e1, ReviewsRecord? e2) {
    return e1?.courtId == e2?.courtId &&
        e1?.userName == e2?.userName &&
        e1?.initials == e2?.initials &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.date == e2?.date;
  }

  @override
  int hash(ReviewsRecord? e) => const ListEquality().hash(
      [e?.courtId, e?.userName, e?.initials, e?.rating, e?.comment, e?.date]);

  @override
  bool isValidKey(Object? o) => o is ReviewsRecord;
}
