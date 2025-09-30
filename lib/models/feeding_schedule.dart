// models/feeding_schedule.dart
import 'package:flutter/material.dart';

class FeedingSchedule {
  final String id;
  final String petId;
  final String foodType;
  final double amount;
  final List<TimeOfDay> times;
  final bool isActive;

  FeedingSchedule({
    required this.id,
    required this.petId,
    required this.foodType,
    required this.amount,
    required this.times,
    this.isActive = true,
  });
}
