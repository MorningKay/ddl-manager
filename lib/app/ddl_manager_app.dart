import 'package:flutter/material.dart';

import '../features/deadlines/presentation/deadline_list_screen.dart';

class DDLManagerApp extends StatelessWidget {
  const DDLManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DDLManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const DeadlineListScreen(),
    );
  }
}
