import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CourtsRecord extends FirestoreRecord {
  CourtsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "pricePerHour" field.
  double? _pricePerHour;
  double get pricePerHour => _pricePerHour ?? 0.0;
  bool hasPricePerHour() => _pricePerHour != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "locationLatLng" field.
  String? _locationLatLng;
  String get locationLatLng => _locationLatLng ?? '';
  bool hasLocationLatLng() => _locationLatLng != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _address = snapshotData['address'] as String?;
    _description = snapshotData['description'] as String?;
    _pricePerHour = castToType<double>(snapshotData['pricePerHour']);
    _rating = castToType<double>(snapshotData['rating']);
    _imageUrl = snapshotData['imageUrl'] as String?;
    _locationLatLng = snapshotData['locationLatLng'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('courts');

  static Stream<CourtsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CourtsRecord.fromSnapshot(s));

  static Future<CourtsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CourtsRecord.fromSnapshot(s));

  static CourtsRecord fromSnapshot(DocumentSnapshot snapshot) => CourtsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CourtsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CourtsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CourtsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CourtsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCourtsRecordData({
  String? name,
  String? address,
  String? description,
  double? pricePerHour,
  double? rating,
  String? imageUrl,
  String? locationLatLng,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'address': address,
      'description': description,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'imageUrl': imageUrl,
      'locationLatLng': locationLatLng,
    }.withoutNulls,
  );

  return firestoreData;
}

class CourtsRecordDocumentEquality implements Equality<CourtsRecord> {
  const CourtsRecordDocumentEquality();

  @override
  bool equals(CourtsRecord? e1, CourtsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.address == e2?.address &&
        e1?.description == e2?.description &&
        e1?.pricePerHour == e2?.pricePerHour &&
        e1?.rating == e2?.rating &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.locationLatLng == e2?.locationLatLng;
  }

  @override
  int hash(CourtsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.address,
        e?.description,
        e?.pricePerHour,
        e?.rating,
        e?.imageUrl,
        e?.locationLatLng
      ]);

  @override
  bool isValidKey(Object? o) => o is CourtsRecord;
}
