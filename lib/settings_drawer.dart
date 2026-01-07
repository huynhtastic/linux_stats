import 'package:flutter/material.dart';

import 'features/cpu/cpu_service.dart';
import 'features/cpu/irix_solaris_switch.dart';

class SettingsDrawer extends StatelessWidget {
  final CPUService cpuService;

  const SettingsDrawer({super.key, required this.cpuService});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IrixSolarisSwitch(cpuService: cpuService),
        ],
      ),
    );
  }
}
