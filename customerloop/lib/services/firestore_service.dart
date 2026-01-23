import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // COLLECTION NAMES
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';

  // CREATE - Add user data
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add user data: $e');
    }
  }

  // CREATE - Add a note
  Future<String> addNote(String uid, Map<String, dynamic> noteData) async {
    try {
      final docRef = await _firestore.collection(notesCollection).add({
        'uid': uid,
        ...noteData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // READ - Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // READ - Get all notes for a user (real-time)
  Stream<QuerySnapshot> getUserNotesStream(String uid) {
    return _firestore
        .collection(notesCollection)
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // READ - Get all notes for a user (one-time)
  Future<List<Map<String, dynamic>>> getUserNotes(String uid) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(notesCollection)
              .where('uid', isEqualTo: uid)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  // READ - Get a specific note
  Future<Map<String, dynamic>?> getNote(String noteId) async {
    try {
      final doc =
          await _firestore.collection(notesCollection).doc(noteId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get note: $e');
    }
  }

  // UPDATE - Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // UPDATE - Update a note
  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(notesCollection).doc(noteId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // DELETE - Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection(notesCollection).doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // DELETE - Delete user data and all their notes
  Future<void> deleteUserData(String uid) async {
    try {
      // Delete user document
      await _firestore.collection(usersCollection).doc(uid).delete();

      // Delete all user's notes
      final notesSnapshot =
          await _firestore
              .collection(notesCollection)
              .where('uid', isEqualTo: uid)
              .get();

      for (var doc in notesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // BATCH OPERATIONS - Delete multiple notes
  Future<void> deleteMultipleNotes(List<String> noteIds) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String noteId in noteIds) {
        batch.delete(_firestore.collection(notesCollection).doc(noteId));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple notes: $e');
    }
  }
}
