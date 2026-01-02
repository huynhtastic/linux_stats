import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const initialStat =
    '1 (test) S 0 0 0 0 0 0 0 0 0 0 100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0';
const initialUptime = '100.0 100.0';

void main() {
  test('testing cpuinfo sync', () async {
    final file = File('/proc/cpuinfo');
    final sw = Stopwatch()..start();

    // --- Start Measurement ---
    final lines = file.readAsLinesSync();
    final model = lines.firstWhere((l) => l.contains('model name'));
    // --- End Measurement ---

    sw.stop();
    print('Sync took: ${sw.elapsedMicroseconds}μs');
    print('Memory used: ${ProcessInfo.currentRss / 1024} KB');
  });

  test('testing cpuinfo async', () async {
    final file = File('/proc/cpuinfo');

    // 1. Create the stream
    final sw = Stopwatch()..start();
    final a = file.openRead();
    // .transform(utf8.decoder) // 2. Convert bytes to text
    // .transform(const LineSplitter()); // 3. Split text into lines
    sw.stop();
    final openTime = sw.elapsedMicroseconds;
    print('Opening took: $openTimeμs');

    sw.reset();
    sw.start();
    final b = a.transform(utf8.decoder);
    sw.stop();
    final decodeTime = sw.elapsedMicroseconds;
    print('Decoding took: $decodeTimeμs');

    sw.reset();
    sw.start();
    final lines = b.transform(const LineSplitter()); // 3. Split text into lines
    sw.stop();
    final splitTime = sw.elapsedMicroseconds;
    print('Splitting took: $splitTimeμs');

    sw.reset();
    sw.start();
    try {
      await for (var line in lines) {
        if (line.startsWith('model name')) {
          // How do we stop here to save resources?
          break;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    sw.stop();
    final searchTime = sw.elapsedMicroseconds;
    print('Searching took: $searchTimeμs');
    print('Total took: ${openTime + decodeTime + splitTime + searchTime}μs');
    print('Memory used: ${ProcessInfo.currentRss / 1024} KB');
  });
}
