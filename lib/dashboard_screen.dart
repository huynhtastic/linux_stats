import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'common.dart' show getColorForUsage;
import 'cpu_service.dart';
import 'gpu_service.dart';
import 'metric_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  final GPUService _gpuService = GPUService();
  final CPUService _cpuService = CPUService();

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
      await _gpuService.readUsage();
      await _cpuService.readCPUUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _gpuService.errorMessage != null
            ? _buildErrorView()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 32),
                    ListenableBuilder(
                      listenable: _gpuService,
                      builder: (context, child) {
                        return MetricGauge(
                          percent: _gpuService.usage,
                          color: getColorForUsage(_gpuService.usage),
                          name: 'GPU USAGE',
                        );
                      },
                    ),
                    const SizedBox(width: 64),
                    ListenableBuilder(
                      listenable: _cpuService,
                      builder: (context, child) {
                        return MetricGauge(
                          percent: _cpuService.usage,
                          color: getColorForUsage(_cpuService.usage),
                          name: 'APP CPU',
                          deviceName: 'PID: $pid',
                        );
                      },
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
            _gpuService.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
