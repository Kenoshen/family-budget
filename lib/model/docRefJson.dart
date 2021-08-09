import 'package:cloud_firestore/cloud_firestore.dart';

/// Deserialize Firebase DocumentReference data type from Firestore
DocumentReference<Map<String, dynamic>>? firestoreDocRefFromJson(dynamic value) {
  if (value == null) {
    return null;
  } else if (value is DocumentReference) {
    return FirebaseFirestore.instance.doc(value.path);
  } else if (value is String) {
    return FirebaseFirestore.instance.doc(value);
  }
  return null;
}

/// This method only stores the "relation" data type back in the Firestore
dynamic firestoreDocRefToJson(dynamic value) => value;

/// Deserialize Firebase DocumentReference data type from Firestore
CollectionReference<Map<String, dynamic>>? firestoreColRefFromJson(dynamic value) {
  if (value == null) {
    return null;
  } else if (value is CollectionReference) {
    return FirebaseFirestore.instance.collection(value.path);
  } else if (value is String) {
    return FirebaseFirestore.instance.collection(value);
  }
  return null;
}

/// This method only stores the "relation" data type back in the Firestore
dynamic firestoreColRefToJson(dynamic value) => value;

/// Deserialize Firebase Timestamp data type from Firestore
Timestamp firestoreTimestampFromJson(dynamic value) {
  return value != null ? Timestamp.fromMicrosecondsSinceEpoch(value) : value;
}

/// This method only stores the "timestamp" data type back in the Firestore
dynamic firestoreTimestampToJson(dynamic value) => value;