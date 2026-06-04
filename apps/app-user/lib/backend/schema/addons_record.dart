import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AddonsRecord extends FirestoreRecord {
  AddonsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _price = castToType<double>(snapshotData['price']);
    _imageUrl = snapshotData['imageUrl'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('addons');

  static Stream<AddonsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AddonsRecord.fromSnapshot(s));

  static Future<AddonsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AddonsRecord.fromSnapshot(s));

  static AddonsRecord fromSnapshot(DocumentSnapshot snapshot) => AddonsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AddonsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AddonsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AddonsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AddonsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAddonsRecordData({
  String? name,
  double? price,
  String? imageUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class AddonsRecordDocumentEquality implements Equality<AddonsRecord> {
  const AddonsRecordDocumentEquality();

  @override
  bool equals(AddonsRecord? e1, AddonsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.price == e2?.price &&
        e1?.imageUrl == e2?.imageUrl;
  }

  @override
  int hash(AddonsRecord? e) =>
      const ListEquality().hash([e?.name, e?.price, e?.imageUrl]);

  @override
  bool isValidKey(Object? o) => o is AddonsRecord;
}
