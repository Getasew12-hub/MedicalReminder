import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/models/user_profile.dart';
import '../../features/medicine/models/medicine.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _medicinesRef(String userId) {
    return _userRef(userId).collection('medicines');
  }

  Stream<UserProfile?> watchUserProfile(
    String userId, {
    required String fallbackEmail,
    required String fallbackName,
  }) {
    return _userRef(userId).snapshots().map(
          (snapshot) => UserProfile.fromFirestore(
            snapshot.id,
            snapshot.data(),
            fallbackEmail: fallbackEmail,
            fallbackName: fallbackName,
          ),
        );
  }

  Future<void> updateUserProfile(UserProfile profile) {
    return _userRef(profile.uid).set(
      profile.toFirestore()
        ..addAll({
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      SetOptions(merge: true),
    );
  }

  Stream<List<Medicine>> watchMedicines(String userId) {
    return _medicinesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Medicine.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> addMedicine(String userId, Medicine medicine) async {
    final doc = await _medicinesRef(userId).add(medicine.toFirestore()
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }));
    return doc.id;
  }

  Future<void> updateMedicine(String userId, Medicine medicine) {
    return _medicinesRef(userId).doc(medicine.id).update(medicine.toFirestore()
      ..addAll({
        'updatedAt': FieldValue.serverTimestamp(),
      }));
  }

  Future<void> deleteMedicine(String userId, String medicineId) {
    return _medicinesRef(userId).doc(medicineId).delete();
  }

  Future<void> updateMedicineStatus({
    required String userId,
    required String medicineId,
    required bool isDone,
    required bool isSkipped,
  }) {
    return _medicinesRef(userId).doc(medicineId).update({
      'isDone': isDone,
      'isSkipped': isSkipped,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
