import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linux_stats/cpu_service.dart';

const initialStat =
    '1 (test) S 0 0 0 0 0 0 0 0 0 0 100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0';
const initialUptime = '100.0 100.0';

void main() {
  late Directory tempDir;
  late File statFile;
  late File uptimeFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('cpu_service_test');
    statFile = File('${tempDir.path}/stat');
    uptimeFile = File('${tempDir.path}/uptime');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('reading CPU usage 1 time shows 0', () async {
    statFile.writeAsStringSync(initialStat);
    uptimeFile.writeAsStringSync(initialUptime);

    final cpuService =
        CPUService(statPath: statFile.path, uptimePath: uptimeFile.path);
    await cpuService.readCPUUsage();

    expect(cpuService.usage, 0);
  });

  test('reading CPU usage 2 times shows 0.1', () async {
    statFile.writeAsStringSync(initialStat);
    uptimeFile.writeAsStringSync(initialUptime);

    final cpuService =
        CPUService(statPath: statFile.path, uptimePath: uptimeFile.path);

    await cpuService.readCPUUsage();

    // Second state: 10 idle ticks (+10), 101.0 uptime (+1.0)
    statFile.writeAsStringSync(
        '1 (test) S 10 0 0 0 0 0 0 0 0 0 100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0');
    uptimeFile.writeAsStringSync('101.0 100.0');

    await cpuService.readCPUUsage();

    expect(cpuService.usage, 0.1);
  });
}
