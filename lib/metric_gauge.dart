import 'package:flutter/material.dart';

import 'device_label.dart';

class MetricGauge extends StatelessWidget {
  final double percent;
  final Color color;

  const MetricGauge({super.key, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'GPU USAGE',
          style: TextStyle(
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
                value: percent,
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
                  'LOAD',
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
        const DeviceLabel(name: 'AMD RADEON RX 7700S'),
      ],
    );
  }
}
