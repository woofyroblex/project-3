//lib/utils/compute_helper.dart
import 'package:flutter/foundation.dart';

Future<String> heavyTask() async {
  return await compute(expensiveCalculation, "InputData");
}

String expensiveCalculation(String input) {
  // Simulate heavy computation
  return "Processed: $input";
}
