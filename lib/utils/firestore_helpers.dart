// utils/firestore_helpers.dart
//
// Firestore stores dates as `Timestamp`, not `DateTime`. These helpers keep
// that conversion in one place instead of repeating it in every model.
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? timestampToDate(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value); // safety net only
  return null;
}

DateTime timestampToDateOrNow(Object? value) =>
    timestampToDate(value) ?? DateTime.now();

Timestamp? dateToTimestamp(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);
