import 'dart:io';

import 'package:flutter/material.dart';

import 'cpu_service.dart';

class IrixSolarisSwitch extends StatelessWidget {
  const IrixSolarisSwitch({super.key, required this.cpuService});

  final CPUService cpuService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cpuService,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                enableTapToDismiss: false,
                preferBelow: false,
                constraints: const BoxConstraints(maxWidth: 350),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                richMessage: _buildTooltipContent(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CPU Mode'),
                    SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: Colors.white54),
                  ],
                ),
              ),
            ),
            ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              isSelected: [
                cpuService.mode == CpuMode.solaris,
                cpuService.mode == CpuMode.irix,
              ],
              onPressed: (index) {
                cpuService.setMode(index == 0 ? CpuMode.solaris : CpuMode.irix);
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
            ),
          ],
        );
      },
    );
  }

  TextSpan _buildTooltipContent(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontSize: 16,
        );
    final boldStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
    final codeStyle = textStyle?.copyWith(
      fontFamily: 'monospace',
      backgroundColor: Colors.white10,
    );
    // final linkStyle = textStyle?.copyWith(
    //   color: Colors.blueAccent,
    //   decoration: TextDecoration.underline,
    // );

    return TextSpan(
      style: textStyle,
      children: [
        TextSpan(text: 'Solaris (default): ', style: boldStyle),
        const TextSpan(
            text:
                'shows CPU Usage from 0 to 100% as an average of usage across all processors\n\n'),
        TextSpan(text: 'Irix: ', style: boldStyle),
        const TextSpan(
            text:
                'shows CPU usage from 0 to 100 * number of available processors on the machine '),
        TextSpan(text: '(${Platform.numberOfProcessors})', style: codeStyle),
        // TODO: When adding url_launcher
        // const TextSpan(text: '\n\nLearn more from '),
        // TextSpan(
        //   text: 'man top',
        //   style: linkStyle,
        //   // In a real app with url_launcher, add TapGestureRecognizer here
        // ),
        // const TextSpan(text: '.'),
      ],
    );
  }
}
