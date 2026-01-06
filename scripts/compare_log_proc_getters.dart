// A simple script to compare the performance of different methods for getting the number of processors.
import 'dart:io';

const numTests = 2;

void main() async {
  for (int i = 0; i < numTests; i++) {
    print('Test ${i + 1}');
    await test();
    print('');
  }
}

Future<void> test() async {
  print("--- CPU Count Method Comparison ---");

  // 1. Method: Platform.numberOfProcessors (Built-in)
  final stopwatch1 = Stopwatch()..start();
  final count1 = Platform.numberOfProcessors;
  stopwatch1.stop();
  print(
      "Method 1 (Built-in): Found $count1 processors in ${stopwatch1.elapsedMicroseconds} μs");

  // 2. Method: Manual /proc/cpuinfo parsing
  final stopwatch2 = Stopwatch()..start();
  final count2 = await countProcessorsFromProc();
  stopwatch2.stop();
  print(
      "Method 2 (Manual):   Found $count2 processors in ${stopwatch2.elapsedMicroseconds} μs");

  // Conclusion
  final factor =
      (stopwatch2.elapsedMicroseconds / stopwatch1.elapsedMicroseconds)
          .toStringAsFixed(1);
  print("-----------------------------------");
  print("Built-in method was $factor times faster than manual parsing.");
}

Future<int> countProcessorsFromProc() async {
  try {
    final file = File('/proc/cpuinfo');
    final lines = await file.readAsLines();

    // In /proc/cpuinfo, each logical processor starts with the word 'processor'
    return lines.where((line) => line.startsWith('processor')).length;
  } catch (e) {
    print("Error reading /proc/cpuinfo: $e");
    return -1;
  }
}
