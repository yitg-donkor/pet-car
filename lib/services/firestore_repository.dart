// services/firestore_repository.dart
//
// One generic, typed repository instead of hand-writing create/get/update/
// delete/upsert for every table. This replaces:
//   - lib/local_db/sqflite_db.dart          (~1200 lines)
//   - lib/services/supa_sync-service.dart   (dead code, was unused anyway)
//   - the duplicate UnifiedSyncService inside offline_providers.dart
//
// Firestore's SDK keeps its own on-device cache and reconciles it with the
// server automatically (as long as you enable persistence in main.dart), so
// there's no manual is_synced/last_modified bookkeeping to maintain here.
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository<T> {
  FirestoreRepository({
    required String collectionPath,
    required T Function(Map<String, dynamic> data, String id) fromFirestore,
    required Map<String, dynamic> Function(T value) toFirestore,
    FirebaseFirestore? firestore,
  }) : _collection = (firestore ?? FirebaseFirestore.instance)
           .collection(collectionPath)
           .withConverter<T>(
             fromFirestore:
                 (snap, _) => fromFirestore(snap.data()!, snap.id),
             toFirestore: (value, _) => toFirestore(value),
           );

  final CollectionReference<T> _collection;

  /// Create a new document with an auto-generated ID. Returns that ID.
  Future<String> add(T value) async {
    final docRef = await _collection.add(value);
    return docRef.id;
  }

  /// Create or overwrite a document at a specific ID.
  Future<void> set(String id, T value) => _collection.doc(id).set(value);

  /// Partial update. [patch] uses your Firestore field names (camelCase),
  /// not the model's Dart field names.
  Future<void> update(String id, Map<String, dynamic> patch) =>
      _collection.doc(id).update(patch);

  Future<void> delete(String id) => _collection.doc(id).delete();

  Future<T?> get(String id) async {
    final snap = await _collection.doc(id).get();
    return snap.data();
  }

  /// Live stream of docs matching [queryBuilder]. Firestore serves this from
  /// its local cache first (instant, works offline) and updates it as the
  /// server confirms writes or pushes changes from other devices.
  Stream<List<T>> watch([
    Query<T> Function(Query<T> query)? queryBuilder,
  ]) {
    Query<T> query = _collection;
    if (queryBuilder != null) query = queryBuilder(query);
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => d.data()).toList(),
    );
  }

  /// One-off fetch (rarely needed over [watch], but handy for exports/reports).
  Future<List<T>> fetch([
    Query<T> Function(Query<T> query)? queryBuilder,
  ]) async {
    Query<T> query = _collection;
    if (queryBuilder != null) query = queryBuilder(query);
    final snap = await query.get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
