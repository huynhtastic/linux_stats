import 'dart:io';

import 'package:flutter/foundation.dart';

class RAMService with ChangeNotifier {
  final String meminfoPath;

  int totalMem = 1;
  int availableMem = 0;

  int get usedMem => totalMem - availableMem;
  double get usage => usedMem / totalMem;

  RAMService({String? meminfoPath})
      : meminfoPath = meminfoPath ?? '/proc/meminfo';

  Future<void> readRAMUsage() async {
    try {
      final meminfoFile = File(meminfoPath);
      final meminfoContent = await meminfoFile.readAsString();
      _getMemUsage(meminfoContent);
      notifyListeners();
    } catch (e) {
      debugPrint('Error reading RAM usage: $e');
    }
  }

  // Assume that MemTotal and MemAvailable are lines 0 and 2
  void _getMemUsage(String meminfoContent) {
    int total = -1;
    int available = -1;

    final lines = meminfoContent.split('\n');
    if (lines[0].startsWith('MemTotal') &&
        lines[2].startsWith('MemAvailable')) {
      total = int.parse(lines[0].split(':')[1].trim().split(' ')[0]);
      available = int.parse(lines[2].split(':')[1].trim().split(' ')[0]);
    } else {
      throw StateError(
          'Unexpected meminfo format: MemTotal or MemAvailable not found');
      // TODO:
      // debugPrint(
      // 'Did not find expected MemTotal or MemAvailable line in meminfo file');
      // debugPrint('iterating through memfile to find MemTotal and MemAvailable');
    }

    totalMem = total;
    availableMem = available;
  }
}
