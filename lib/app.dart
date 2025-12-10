import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class GPUApp extends StatelessWidget {
  const GPUApp({super.key});

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
        child:
            _error ? _buildErrorView() : _buildDashboard(percent, statusColor),
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

  Widget _buildDashboard(double percent, Color color) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor, size: 20, color: Colors.white70),
              SizedBox(width: 12),
              Text(
                'AMD RADEON RX 7700S', // Hardcoded based on lspci
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
