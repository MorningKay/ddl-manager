import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:ddl_manager/features/deadlines/presentation/deadline_sections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds in-progress and closed boards with expected ordering', () {
    final now = DateTime(2026, 6, 4, 12);
    final board = buildDeadlineBoard([
      _deadline(id: 1, title: 'Later active', dueAt: DateTime(2026, 6, 5, 18)),
      _deadline(
        id: 2,
        title: 'Earlier active',
        dueAt: DateTime(2026, 6, 4, 18),
      ),
      _deadline(id: 3, title: 'Closed active', dueAt: DateTime(2026, 6, 4, 10)),
      _deadline(id: 4, title: 'TBA first', dueAt: null),
      _deadline(id: 5, title: 'TBA second', dueAt: null),
      _deadline(
        id: 6,
        title: 'Completed active',
        dueAt: DateTime(2026, 6, 6, 10),
        isCompleted: true,
      ),
      _deadline(
        id: 7,
        title: 'Completed closed',
        dueAt: DateTime(2026, 6, 3, 10),
        isCompleted: true,
      ),
    ], now: now);

    expect(board.inProgress.scheduled.map((deadline) => deadline.title), [
      'Earlier active',
      'Later active',
    ]);
    expect(board.inProgress.dateUnannounced.map((deadline) => deadline.title), [
      'TBA first',
      'TBA second',
    ]);
    expect(board.inProgress.completed.map((deadline) => deadline.title), [
      'Completed active',
    ]);
    expect(board.closed.scheduled.map((deadline) => deadline.title), [
      'Closed active',
    ]);
    expect(board.closed.completed.map((deadline) => deadline.title), [
      'Completed closed',
    ]);
  });

  test('collects tag options and filters by all selected tags', () {
    final now = DateTime(2026, 6, 4, 12);
    final board = buildDeadlineBoard([
      _deadline(
        id: 1,
        title: 'Required exam',
        dueAt: DateTime(2026, 6, 5, 18),
        tags: ['必修课', '考试'],
      ),
      _deadline(
        id: 2,
        title: 'Summer camp',
        dueAt: DateTime(2026, 6, 6, 18),
        tags: ['科学院', '夏令营'],
      ),
      _deadline(
        id: 3,
        title: 'Standalone exam',
        dueAt: DateTime(2026, 6, 7, 18),
        tags: ['考试'],
      ),
    ], now: now);

    expect(deadlineTagOptions([...board.inProgress.scheduled]), [
      '考试',
      '夏令营',
      '必修课',
      '科学院',
    ]);

    final filtered = filterDeadlineBoardColumnByTags(board.inProgress, {
      '必修课',
      '考试',
    });

    expect(filtered.scheduled.map((deadline) => deadline.title), [
      'Required exam',
    ]);
  });
}

Deadline _deadline({
  required int id,
  required String title,
  required DateTime? dueAt,
  bool isCompleted = false,
  List<String> tags = const [],
}) {
  final createdAt = DateTime(2026, 6, 1, 9, id);
  return Deadline(
    id: id,
    title: title,
    dueAt: dueAt,
    notes: '',
    priority: DeadlinePriority.medium,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: createdAt,
    tags: tags,
  );
}
