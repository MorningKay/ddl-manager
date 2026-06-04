import 'package:ddl_manager/app/app_language.dart';
import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:ddl_manager/features/deadlines/presentation/deadline_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats future remaining time with a detailed countdown', () {
    final now = DateTime(2026, 6, 4, 12);

    expect(
      formatRemainingTime(
        _deadline(dueAt: DateTime(2026, 6, 5, 14, 30), isCompleted: true),
        now: now,
        language: AppLanguage.zh,
      ),
      '剩余 1天2小时30分钟',
    );
  });

  test('formats unannounced dates as a compact placeholder', () {
    final now = DateTime(2026, 6, 4, 12);

    expect(
      formatRemainingTime(
        _deadline(dueAt: null),
        now: now,
        language: AppLanguage.zh,
      ),
      '—',
    );
  });

  test(
    'formats overdue deadlines as a closed date marker in the same year',
    () {
      final now = DateTime(2026, 6, 4, 12);

      expect(
        formatRemainingTime(
          _deadline(dueAt: DateTime(2026, 6, 3, 10)),
          now: now,
          language: AppLanguage.zh,
        ),
        '已截止 · 06月03日 10:00',
      );
    },
  );

  test('keeps the year in overdue markers when the deadline crosses years', () {
    final now = DateTime(2026, 1, 1, 12);

    expect(
      formatRemainingTime(
        _deadline(dueAt: DateTime(2025, 12, 31, 23)),
        now: now,
        language: AppLanguage.zh,
      ),
      '已截止 · 2025年12月31日 23:00',
    );
  });
}

Deadline _deadline({required DateTime? dueAt, bool isCompleted = false}) {
  final createdAt = DateTime(2026, 6, 1, 9);
  return Deadline(
    id: 1,
    title: 'Deadline',
    dueAt: dueAt,
    notes: '',
    priority: DeadlinePriority.medium,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
