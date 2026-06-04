import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/deadlines/presentation/deadline_list_screen.dart';
import 'app_language.dart';

class DDLManagerApp extends ConsumerWidget {
  const DDLManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return MaterialApp(
      title: 'DDLManager',
      locale: switch (language) {
        AppLanguage.zh => const Locale('zh', 'CN'),
        AppLanguage.en => const Locale('en'),
      },
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const DeadlineListScreen(),
    );
  }
}
