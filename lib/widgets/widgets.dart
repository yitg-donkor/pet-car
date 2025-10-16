import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget universalButton(
  BuildContext context,
  WidgetRef ref, {
  required String label,
  required VoidCallback onpressed,
}) {
  return ElevatedButton(onPressed: onpressed, child: Text(label));
}
