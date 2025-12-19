import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'metric_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _gpuPath = '/sys/class/drm/card2/device/gpu_busy_percent';

  String _usage = '0';
  String _cpuUsage = '0.0';
  Timer? _timer;
  bool _error = false;
  String _errorMessage = '';

  int? _lastCpuTicks;
  double? _lastCpuTime;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      await _readGPUUsage();
      await _readCPUUsage();
    });
  }

  Future<void> _readGPUUsage() async {
    try {
      final file = File(_gpuPath);
      if (!file.existsSync()) {
        if (mounted) {
          setState(() {
            _error = true;
            _errorMessage = 'GPU file not found at path:\n$_gpuPath';
          });
        }
        return;
      }

      final contents = await file.readAsString();
      final trimmed = contents.trim();

      if (mounted) {
        setState(() {
          _usage = trimmed;
          _error = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _readCPUUsage() async {
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

          if (mounted) {
            setState(() {
              _cpuUsage = percent.toStringAsFixed(1);
            });
          }
        }
      }

      _lastCpuTicks = currentTicks;
      _lastCpuTime = currentUptime;
    } catch (e) {
      // debugPrint('Error reading CPU usage: $e');
    }
  }

  double get _parsedUsage {
    final val = double.tryParse(_usage);
    return (val ?? 0) / 100.0;
  }

  double get _parsedCpuUsage {
    final val = double.tryParse(_cpuUsage);
    return (val ?? 0) / 100.0;
  }

  Color _getStatusColor(double percent) {
    if (percent < 0.3) {
      return Colors.greenAccent;
    } else if (percent < 0.7) {
      return Colors.amberAccent;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error
            ? _buildErrorView()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 32),
                    MetricGauge(
                      percent: _parsedUsage,
                      color: _getStatusColor(_parsedUsage),
                      name: 'GPU USAGE',
                    ),
                    const SizedBox(width: 64),
                    MetricGauge(
                      percent: _parsedCpuUsage,
                      color: _getStatusColor(_parsedCpuUsage),
                      name: 'APP CPU',
                      deviceName: 'PID: $pid',
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error Reading GPU Stats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
