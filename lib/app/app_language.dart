import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { zh, en }

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppLanguage.zh;
  }

  void setLanguage(AppLanguage language) {
    state = language;
  }
}
