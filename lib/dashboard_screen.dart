import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linux_stats/settings_drawer.dart';

import 'common.dart';
import 'features/cpu/cpu_metric_gauge.dart';
import 'features/cpu/cpu_service.dart';
import 'gpu_service.dart';
import 'metric_gauge.dart';
import 'ram_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  final GPUService _gpuService = GPUService();
  final CPUService _cpuService = CPUService();
  final RAMService _ramService = RAMService();

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
      await _ramService.readRAMUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(cpuService: _cpuService),
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
                    CPUMetricGauge(cpuService: _cpuService),
                    const SizedBox(width: 64),
                    ListenableBuilder(
                      listenable: _ramService,
                      builder: (context, child) {
                        return MetricGauge(
                          percent: _ramService.usage,
                          color: getColorForUsage(_ramService.usage),
                          name: 'RAM',
                          deviceName:
                              'RAM: ${_ramService.usedMem.kbToGb.toStringAsFixed(2)}GB / ${_ramService.totalMem.kbToGb.toStringAsFixed(2)}GB',
                          gaugeSubtext: 'USED',
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
