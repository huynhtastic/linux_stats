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
