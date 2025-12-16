import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      title: 'AMD GPU Monitor',
      theme: ThemeData.light().copyWith(
        // scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
