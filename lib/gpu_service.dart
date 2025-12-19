import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

const String _gpuPath = '/sys/class/drm/card2/device/gpu_busy_percent';

class GPUService with ChangeNotifier {
  String _usage = '0';

  String? errorMessage;

  GPUService();

  Future<void> readUsage() async {
    try {
      final file = File(_gpuPath);
      if (!file.existsSync()) {
        errorMessage = 'GPU file not found at path:\n$_gpuPath';
        return;
      }

      final contents = await file.readAsString();
      final trimmed = contents.trim();

      _usage = trimmed;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  double get usage {
    final val = double.tryParse(_usage);
    return (val ?? 0) / 100.0;
  }
}
