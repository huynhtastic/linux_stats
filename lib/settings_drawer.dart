import 'package:flutter/material.dart';

import 'features/cpu/cpu_service.dart';

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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('CPU Mode'),
          ),
          ListenableBuilder(
            listenable: cpuService,
            builder: (context, _) {
              return ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [
                  cpuService.mode == CpuMode.solaris,
                  cpuService.mode == CpuMode.irix,
                ],
                onPressed: (index) {
                  cpuService
                      .setMode(index == 0 ? CpuMode.solaris : CpuMode.irix);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Solaris'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Irix'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
