import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:ddl_manager/features/deadlines/presentation/deadline_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deadline progress window keeps the farthest typical item near 30%', () {
    final now = DateTime(2026, 6, 4, 12);
    final deadlines = [
      _deadline(dueAt: now.add(const Duration(days: 21))),
      _deadline(dueAt: now.add(const Duration(days: 63))),
    ];
    final window = deadlineProgressWindow(deadlines, now);

    expect(window, const Duration(days: 90));

    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.add(const Duration(days: 63))),
        now,
        visibleWindow: window,
      ),
      closeTo(0.3, 0.001),
    );
    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.add(const Duration(days: 21))),
        now,
        visibleWindow: window,
      ),
      closeTo(0.766, 0.001),
    );
  });

  test(
    'deadline progress window ignores a distant outlier in a larger board',
    () {
      final now = DateTime(2026, 6, 4, 12);
      final window = deadlineProgressWindow([
        _deadline(dueAt: now.add(const Duration(days: 1))),
        _deadline(dueAt: now.add(const Duration(days: 2))),
        _deadline(dueAt: now.add(const Duration(days: 3))),
        _deadline(dueAt: now.add(const Duration(days: 4))),
        _deadline(dueAt: now.add(const Duration(days: 365))),
      ], now);

      expect(window, const Duration(days: 7));
    },
  );

  test(
    'deadline progress window falls back when there are no future dates',
    () {
      final now = DateTime(2026, 6, 4, 12);

      expect(
        deadlineProgressWindow([
          _deadline(dueAt: null),
          _deadline(dueAt: now.subtract(const Duration(hours: 1))),
        ], now),
        const Duration(days: 90),
      );
    },
  );

  test('deadline progress window includes completed future deadlines', () {
    final now = DateTime(2026, 6, 4, 12);

    expect(
      deadlineProgressWindow([
        _deadline(dueAt: now.add(const Duration(days: 7)), isCompleted: true),
      ], now),
      const Duration(days: 10),
    );
  });

  test('deadline countdown progress clamps boundary states', () {
    final now = DateTime(2026, 6, 4, 12);

    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.subtract(const Duration(minutes: 1))),
        now,
      ),
      1,
    );
    expect(deadlineCountdownProgress(_deadline(dueAt: null), now), 0);
    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.add(const Duration(days: 1)), isCompleted: true),
        now,
        visibleWindow: const Duration(days: 10),
      ),
      0.9,
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
