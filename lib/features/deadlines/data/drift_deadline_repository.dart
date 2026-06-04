import 'package:drift/drift.dart';

import '../domain/deadline.dart';
import '../domain/deadline_repository.dart';
import 'local/app_database.dart';

class DriftDeadlineRepository implements DeadlineRepository {
  DriftDeadlineRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Stream<List<Deadline>> watchDeadlines() {
    return _orderedSelect().watch().map(_mapRows);
  }

  @override
  Future<List<Deadline>> listDeadlines() async {
    final rows = await _orderedSelect().get();
    return _mapRows(rows);
  }

  @override
  Future<int> createDeadline(DeadlineDraft draft) {
    final now = _now();
    return _database
        .into(_database.deadlineEntries)
        .insert(
          DeadlineEntriesCompanion.insert(
            title: _cleanTitle(draft.title),
            dueAt: draft.dueAt,
            notes: Value(draft.notes.trim()),
            priority: Value(draft.priority.name),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> updateDeadline(int id, DeadlineDraft draft) async {
    final updatedRows =
        await (_database.update(
          _database.deadlineEntries,
        )..where((entry) => entry.id.equals(id))).write(
          DeadlineEntriesCompanion(
            title: Value(_cleanTitle(draft.title)),
            dueAt: Value(draft.dueAt),
            notes: Value(draft.notes.trim()),
            priority: Value(draft.priority.name),
            updatedAt: Value(_now()),
          ),
        );

    if (updatedRows == 0) {
      throw StateError('Deadline $id was not found.');
    }
  }

  @override
  Future<void> deleteDeadline(int id) async {
    final deletedRows = await (_database.delete(
      _database.deadlineEntries,
    )..where((entry) => entry.id.equals(id))).go();

    if (deletedRows == 0) {
      throw StateError('Deadline $id was not found.');
    }
  }

  @override
  Future<void> toggleCompleted(int id, bool isCompleted) async {
    final updatedRows =
        await (_database.update(
          _database.deadlineEntries,
        )..where((entry) => entry.id.equals(id))).write(
          DeadlineEntriesCompanion(
            isCompleted: Value(isCompleted),
            updatedAt: Value(_now()),
          ),
        );

    if (updatedRows == 0) {
      throw StateError('Deadline $id was not found.');
    }
  }

  @override
  Future<void> close() => _database.close();

  SimpleSelectStatement<$DeadlineEntriesTable, DeadlineRow> _orderedSelect() {
    return _database.select(_database.deadlineEntries)..orderBy([
      (entry) => OrderingTerm.asc(entry.isCompleted),
      (entry) => OrderingTerm.asc(entry.dueAt),
      (entry) => OrderingTerm.asc(entry.createdAt),
    ]);
  }

  List<Deadline> _mapRows(List<DeadlineRow> rows) {
    return rows.map(_mapRow).toList(growable: false);
  }

  Deadline _mapRow(DeadlineRow row) {
    return Deadline(
      id: row.id,
      title: row.title,
      dueAt: row.dueAt,
      notes: row.notes,
      priority: parseDeadlinePriority(row.priority),
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  String _cleanTitle(String title) {
    final cleaned = title.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty.');
    }
    return cleaned;
  }
}
