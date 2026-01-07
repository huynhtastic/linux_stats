import 'dart:io';

import 'package:flutter/material.dart';

import '../../common.dart';
import 'models/cpu_info.dart';

enum CpuMode { irix, solaris }

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
      : _statPath = statPath ?? '/proc/stat',
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

  CpuMode _mode = CpuMode.solaris;
  CpuMode get mode => _mode;

  void setMode(CpuMode mode) {
    _mode = mode;
    notifyListeners();
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
          var percent =
              (Platform.numberOfProcessors - (deltaIdleTime / deltaTotalTime)) *
                  100;

          if (_mode == CpuMode.solaris) {
            percent = percent / Platform.numberOfProcessors;
          }

          _usage = percent.toStringAsFixed(1);
          notifyListeners();
        }
      }

      _lastIdleTicks = idleTicks;
      _lastUptime = currentUptime;
    } catch (e) {
      debugPrint('Error reading CPU usage: $e');
    }
  }
}

Future<int> _getIdleTicks(String statPath) async {
  final statFile = File(statPath);
  final rawStat = await statFile.readAsLines();

  return _extractIdleTicks(rawStat[0]);
}

int _extractIdleTicks(String rawStat) {
  final idleTicks = rawStat.trim().split(RegExp(r'\s+'))[4];

  return int.parse(idleTicks);
}

Future<double> _getUptime(String uptimePath) async {
  final uptimeFile = File(uptimePath);
  final uptimeContent = await uptimeFile.readAsString();
  return double.parse(uptimeContent.split(' ')[0]);
}
