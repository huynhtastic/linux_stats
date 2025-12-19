import 'dart:io';

import 'package:flutter/material.dart';

import 'common.dart';

class CPUService with ChangeNotifier {
  int? _lastCpuTicks;
  double? _lastCpuTime;

  String _usage = '0';
  double get usage => parseUsage(_usage);

  Future<void> readCPUUsage() async {
    try {
      final statFile = File('/proc/self/stat');
      final statContent = await statFile.readAsString();

      // Handle potential spaces in filename within parentheses
      final rightParenIndex = statContent.lastIndexOf(')');
      if (rightParenIndex == -1) return;

      final stats = statContent
          .substring(rightParenIndex + 1)
          .trim()
          .split(RegExp(r'\s+'));

      // man proc:
      // 14: utime (index 11 after state)
      // 15: stime (index 12 after state)
      // stats[0] is state (3rd field in man pages)
      // So indices are offset by 3 from man page index if we count from 1.
      // 1-based: 14, 15
      // 0-based from file start: 13, 14
      // 0-based after parens (start at state):
      // 14 - 3 = 11
      // 15 - 3 = 12

      if (stats.length < 13) return;

      final utime = int.parse(stats[11]);
      final stime = int.parse(stats[12]);
      final currentTicks = utime + stime;

      final uptimeFile = File('/proc/uptime');
      final uptimeContent = await uptimeFile.readAsString();
      final currentUptime = double.parse(uptimeContent.split(' ')[0]);

      if (_lastCpuTicks != null && _lastCpuTime != null) {
        final deltaTicks = currentTicks - _lastCpuTicks!;
        final deltaTime = currentUptime - _lastCpuTime!;

        if (deltaTime > 0) {
          // CLK_TCK is 100 on most Linux systems
          final cpuSeconds = deltaTicks / 100.0;
          final percent = (cpuSeconds / deltaTime) * 100;

          _usage = percent.toStringAsFixed(1);
          notifyListeners();
        }
      }

      _lastCpuTicks = currentTicks;
      _lastCpuTime = currentUptime;
    } catch (e) {
      // debugPrint('Error reading CPU usage: $e');
    }
  }
}
