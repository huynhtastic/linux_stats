import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'device_label.dart';

class MetricGauge extends StatelessWidget {
  final double percent;
  final Color color;
  final String name;
  final String gaugeSubtext;
  final String deviceName;

  const MetricGauge({
    super.key,
    required this.percent,
    required this.color,
    required this.name,
    this.gaugeSubtext = 'LOAD',
    this.deviceName = 'AMD RADEON RX 7700S',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: 20,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(percent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  gaugeSubtext,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 60),
        DeviceLabel(name: deviceName),
      ],
    );
  }
}

@Preview(name: 'Metric Gauge')
Widget buildPreview() {
  return const MetricGauge(
    name: 'gpu usage',
    percent: 0.72,
    color: Colors.amberAccent,
  );
}
