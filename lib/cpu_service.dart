import 'dart:io';

import 'package:flutter/material.dart';

import 'common.dart';

class CPUService with ChangeNotifier {
  final String _statPath;
  final String _uptimePath;

  int? _lastCpuTicks;
  double? _lastCpuTime;

  String _usage = '0';
  double get usage => parseUsage(_usage);

  CPUService({String? statPath, String? uptimePath})
      : _statPath = statPath ?? '/proc/self/stat',
        _uptimePath = uptimePath ?? '/proc/uptime';

  Future<void> readCPUUsage() async {
    try {
      final elapsedTicks = await _getElapsedTicks(_statPath);
      final currentUptime = await _getUptime(_uptimePath);

      // Can only calculate usage if we have a previous value
      final canCalculateUsage = _lastCpuTicks != null && _lastCpuTime != null;
      if (canCalculateUsage) {
        final deltaTicks = elapsedTicks - _lastCpuTicks!;
        final deltaTime = currentUptime - _lastCpuTime!;

        if (deltaTime > 0) {
          // TODO: Get CLK_TCK from the system
          // CLK_TCK is 100 on most Linux systems
          final cpuSeconds = deltaTicks / 100.0;
          final percent = (cpuSeconds / deltaTime) * 100;

          _usage = percent.toStringAsFixed(1);
          notifyListeners();
        }
      }

      _lastCpuTicks = elapsedTicks;
      _lastCpuTime = currentUptime;
    } catch (e) {
      // debugPrint('Error reading CPU usage: $e');
    }
  }
}

// Get utime and stime from stat and add them
Future<int> _getElapsedTicks(String statPath) async {
  final statFile = File(statPath);
  final rawStat = await statFile.readAsString();

  final stats = _extractStats(rawStat);
  return _computeElapsedTicks(stats);
}

// Extract only the stats from the stat file by removing the first 2 entries
List<String> _extractStats(String rawStat) {
  // Remove first 2 entries to handle spaces in filename within parentheses
  final rightParenIndex = rawStat.lastIndexOf(')');
  if (rightParenIndex == -1) throw StateError('Unexpected stat file format');

  final stats =
      rawStat.substring(rightParenIndex + 1).trim().split(RegExp(r'\s+'));

  if (stats.length < 13) {
    throw StateError('Did not find expected stats in stat file');
  }

  return stats;
}

// Add utime and stime at indicies 14 & 15
// (indices 11 and 12 after removing first 2 entries)
int _computeElapsedTicks(List<String> stats) {
  final utime = int.parse(stats[11]);
  final stime = int.parse(stats[12]);
  return utime + stime;
}

Future<double> _getUptime(String uptimePath) async {
  final uptimeFile = File(uptimePath);
  final uptimeContent = await uptimeFile.readAsString();
  return double.parse(uptimeContent.split(' ')[0]);
}
