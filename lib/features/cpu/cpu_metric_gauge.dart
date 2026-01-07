import 'package:flutter/material.dart';
import 'package:linux_stats/features/cpu/cpu_service.dart';

import '../../common.dart';
import '../../metric_gauge.dart';

class CPUMetricGauge extends StatelessWidget {
  final CPUService cpuService;

  const CPUMetricGauge({super.key, required this.cpuService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cpuService,
      builder: (context, child) {
        return MetricGauge(
          percent: cpuService.usage,
          color: getColorForUsage(cpuService.usage),
          name: 'CPU',
          deviceName: 'CPU: ${cpuService.cpuInfo.name}',
        );
      },
    );
  }
}
