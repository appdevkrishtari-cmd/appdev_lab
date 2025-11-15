import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // path: notes/{uid}/{yyyy-MM-dd} -> document with fields {text, updatedAt}
  DocumentReference<Map<String, dynamic>> _noteDoc(String uid, DateTime date) {
    final dayId =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _db.collection('notes').doc(uid).collection('days').doc(dayId);
  }

  Future<String?> getNote(String uid, DateTime date) async {
    try {
      final doc = await _noteDoc(uid, date).get();
      if (!doc.exists) return null;
      return doc.data()?['text'] as String?;
    } catch (e) {
      print('getNote error: $e');
      return null;
    }
  }

  Future<void> setNote(String uid, DateTime date, String text) async {
    await _noteDoc(uid, date).set({
      'text': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteNote(String uid, DateTime date) async {
    await _noteDoc(uid, date).delete();
  }
}
