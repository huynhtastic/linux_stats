// Color mapping based on load
import 'package:flutter/material.dart' show Color, Colors;

Color getColorForUsage(double usage) {
  Color statusColor;
  if (usage < 0.3) {
    statusColor = Colors.greenAccent;
  } else if (usage < 0.7) {
    statusColor = Colors.amberAccent;
  } else {
    statusColor = Colors.redAccent;
  }

  return statusColor;
}

double parseUsage(String usage) {
  final val = double.tryParse(usage);
  return (val ?? 0) / 100.0;
}

extension MemoryExtension on num {
  double get kbToMb => this / 1024;
  double get kbToGb => this / 1024 / 1024;
}
