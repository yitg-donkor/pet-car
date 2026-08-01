import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_log.dart';
import '../models/medical_record.dart';

class ActivityLogLocalDB {
  Future<List<ActivityLog>> getActivityLogsForPet(String petId) async {
    final collection = FirebaseFirestore.instance
        .collection('activity_logs')
        .withConverter<ActivityLog>(
          fromFirestore:
              (snapshot, _) =>
                  ActivityLog.fromFirestore(snapshot.data() ?? {}, snapshot.id),
          toFirestore: (log, _) => log.toFirestore(),
        );

    final snap = await collection.where('petId', isEqualTo: petId).get();
    return snap.docs.map((doc) => doc.data()).toList();
  }
}

class MedicalRecordLocalDB {
  Future<List<MedicalRecord>> getMedicalRecordsForPet(String petId) async {
    final collection = FirebaseFirestore.instance
        .collection('medical_records')
        .withConverter<MedicalRecord>(
          fromFirestore:
              (snapshot, _) => MedicalRecord.fromFirestore(
                snapshot.data() ?? {},
                snapshot.id,
              ),
          toFirestore: (record, _) => record.toFirestore(),
        );

    final snap = await collection.where('petId', isEqualTo: petId).get();
    return snap.docs.map((doc) => doc.data()).toList();
  }
}
