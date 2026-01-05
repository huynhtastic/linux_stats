import 'dart:io';

import 'package:flutter/material.dart';

import 'common.dart';

class CPUService with ChangeNotifier {
  final String _statPath;
  final String _uptimePath;
  final String _cpuInfoPath;

  int? _lastIdleTicks;
  double? _lastUptime;

  String _usage = '0';
  double get usage => parseUsage(_usage);

  CPUInfo cpuInfo = CPUInfo();

  CPUService({String? statPath, String? uptimePath, String? cpuInfoPath})
      : _statPath = statPath ?? '/proc/self/stat',
        _uptimePath = uptimePath ?? '/proc/uptime',
        _cpuInfoPath = cpuInfoPath ?? '/proc/cpuinfo' {
    readCPUInfo();
  }

  Future<void> readCPUInfo() async {
    try {
      final cpuInfoFile = File(_cpuInfoPath);
      final cpuInfoContent = await cpuInfoFile.readAsString();
      final cpuInfo = _extractCPUInfo(cpuInfoContent);
      this.cpuInfo.name = cpuInfo.name;
      notifyListeners();
    } catch (e) {
      cpuInfo.name = 'Unknown';
    }
  }

  CPUInfo _extractCPUInfo(String cpuInfoContent) {
    final cpuInfo = CPUInfo();
    final lines = cpuInfoContent.split('\n');
    for (final line in lines) {
      if (line.startsWith('model name')) {
        cpuInfo.name = line.split(':')[1].trim();
        break;
      }
    }
    return cpuInfo;
  }

  // Grab idle ticks, convert to seconds, then calculate usage
  Future<void> readCPUUsage() async {
    try {
      final idleTicks = await _getIdleTicks(_statPath);
      final currentUptime = await _getUptime(_uptimePath);

      // Can only calculate usage if we have a previous value
      final canCalculateUsage = _lastIdleTicks != null && _lastUptime != null;
      if (canCalculateUsage) {
        final deltaIdleTicks = idleTicks - _lastIdleTicks!;
        final deltaTotalTime = currentUptime - _lastUptime!;

        if (deltaTotalTime > 0) {
          // TODO: Get CLK_TCK from the system
          // CLK_TCK is 100 on most Linux systems
          final deltaIdleTime = deltaIdleTicks / 100.0;
          final percent = (deltaIdleTime / deltaTotalTime) * 100;

          _usage = percent.toStringAsFixed(1);
          notifyListeners();
        }
      }

      _lastIdleTicks = idleTicks;
      _lastUptime = currentUptime;
    } catch (e) {
      // debugPrint('Error reading CPU usage: $e');
    }
  }
}

class CPUInfo {
  String name;

  CPUInfo({this.name = ''});
}

Future<int> _getIdleTicks(String statPath) async {
  final statFile = File(statPath);
  final rawStat = await statFile.readAsString();

  return _extractIdleTicks(rawStat);
}

// Extract only the stats from the stat file by removing the first 2 entries
int _extractIdleTicks(String rawStat) {
  // Remove first 2 entries to handle spaces in filename within parentheses
  final rightParenIndex = rawStat.lastIndexOf(')');
  if (rightParenIndex == -1) throw StateError('Unexpected stat file format');

  final stats =
      rawStat.substring(rightParenIndex + 1).trim().split(RegExp(r'\s+'));

  if (stats.length < 13) {
    throw StateError('Did not find expected stats in stat file');
  }

  return int.parse(stats[1]);
}

Future<double> _getUptime(String uptimePath) async {
  final uptimeFile = File(uptimePath);
  final uptimeContent = await uptimeFile.readAsString();
  return double.parse(uptimeContent.split(' ')[0]);
}
