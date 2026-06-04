import 'package:ddl_manager/features/deadlines/data/drift_deadline_repository.dart';
import 'package:ddl_manager/features/deadlines/data/local/app_database.dart';
import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftDeadlineRepository repository;
  late DateTime currentTime;

  setUp(() {
    currentTime = DateTime(2026, 6, 1, 9);
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftDeadlineRepository(database, now: () => currentTime);
  });

  tearDown(() async {
    await repository.close();
  });

  test('create returns the new deadline in the list', () async {
    final dueAt = DateTime(2026, 6, 10, 17);

    await repository.createDeadline(
      DeadlineDraft(
        title: 'Submit report',
        dueAt: dueAt,
        notes: 'Final draft',
        priority: DeadlinePriority.high,
      ),
    );

    final deadlines = await repository.listDeadlines();

    expect(deadlines, hasLength(1));
    expect(deadlines.single.title, 'Submit report');
    expect(deadlines.single.dueAt, dueAt);
    expect(deadlines.single.notes, 'Final draft');
    expect(deadlines.single.priority, DeadlinePriority.high);
    expect(deadlines.single.isCompleted, isFalse);
  });

  test('create can store a deadline with an unannounced date', () async {
    await repository.createDeadline(
      const DeadlineDraft(
        title: 'Wait for contest schedule',
        dueAt: null,
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    final deadlines = await repository.listDeadlines();

    expect(deadlines.single.title, 'Wait for contest schedule');
    expect(deadlines.single.dueAt, isNull);
  });

  test('update changes editable fields and updatedAt', () async {
    final id = await repository.createDeadline(
      DeadlineDraft(
        title: 'Original title',
        dueAt: DateTime(2026, 6, 10, 17),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );
    final before = (await repository.listDeadlines()).single;

    currentTime = DateTime(2026, 6, 1, 10);
    await repository.updateDeadline(
      id,
      DeadlineDraft(
        title: 'Updated title',
        dueAt: DateTime(2026, 6, 11, 9, 30),
        notes: 'Updated notes',
        priority: DeadlinePriority.low,
      ),
    );

    final after = (await repository.listDeadlines()).single;

    expect(after.title, 'Updated title');
    expect(after.dueAt, DateTime(2026, 6, 11, 9, 30));
    expect(after.notes, 'Updated notes');
    expect(after.priority, DeadlinePriority.low);
    expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
  });

  test('update can clear the due date', () async {
    final id = await repository.createDeadline(
      DeadlineDraft(
        title: 'Original title',
        dueAt: DateTime(2026, 6, 10, 17),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    currentTime = DateTime(2026, 6, 1, 10);
    await repository.updateDeadline(
      id,
      const DeadlineDraft(
        title: 'Original title',
        dueAt: null,
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    final after = (await repository.listDeadlines()).single;

    expect(after.dueAt, isNull);
  });

  test('toggle complete moves item after active deadlines', () async {
    final completedId = await repository.createDeadline(
      DeadlineDraft(
        title: 'Completed task',
        dueAt: DateTime(2026, 6, 10, 17),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Active task',
        dueAt: DateTime(2026, 6, 11, 17),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    await repository.toggleCompleted(completedId, true);
    final deadlines = await repository.listDeadlines();

    expect(deadlines.first.title, 'Active task');
    expect(deadlines.last.title, 'Completed task');
    expect(deadlines.last.isCompleted, isTrue);
  });

  test('delete removes the deadline from the list', () async {
    final id = await repository.createDeadline(
      DeadlineDraft(
        title: 'Remove me',
        dueAt: DateTime(2026, 6, 10, 17),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    await repository.deleteDeadline(id);

    expect(await repository.listDeadlines(), isEmpty);
  });
}
