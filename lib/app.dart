import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AMD GPU Monitor',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const GPUStatsScreen(),
    );
  }
}

class GPUStatsScreen extends StatefulWidget {
  const GPUStatsScreen({super.key});

  @override
  State<GPUStatsScreen> createState() => _GPUStatsScreenState();
}

class _GPUStatsScreenState extends State<GPUStatsScreen> {
  static const String _gpuPath = '/sys/class/drm/card2/device/gpu_busy_percent';

  String _usage = '0';
  Timer? _timer;
  bool _error = false;
  String _errorMessage = '';

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

  double get _parsedUsage {
    final val = double.tryParse(_usage);
    return (val ?? 0) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final percent = _parsedUsage;

    // Color mapping based on load
    Color statusColor;
    if (percent < 0.3) {
      statusColor = Colors.greenAccent;
    } else if (percent < 0.7) {
      statusColor = Colors.amberAccent;
    } else {
      statusColor = Colors.redAccent;
    }

    return Scaffold(
      body: Center(
        child: _error
            ? _buildErrorView()
            : Dashboard(
                percent: percent,
                color: statusColor,
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
