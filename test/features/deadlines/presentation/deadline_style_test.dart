import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:ddl_manager/features/deadlines/presentation/deadline_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deadline countdown progress uses a fixed 90-day window', () {
    final now = DateTime(2026, 6, 4, 12);

    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.add(const Duration(days: 90))),
        now,
      ),
      0,
    );
    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.add(const Duration(days: 63))),
        now,
      ),
      closeTo(0.3, 0.001),
    );
    expect(
      deadlineCountdownProgress(
        _deadline(dueAt: now.subtract(const Duration(minutes: 1))),
        now,
      ),
      1,
    );
  });
}

Deadline _deadline({required DateTime dueAt}) {
  final createdAt = DateTime(2026, 6, 1, 9);
  return Deadline(
    id: 1,
    title: 'Deadline',
    dueAt: dueAt,
    notes: '',
    priority: DeadlinePriority.medium,
    isCompleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
