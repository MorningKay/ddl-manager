import 'dart:convert';

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
            dueAt: Value(draft.dueAt),
            notes: Value(draft.notes.trim()),
            priority: Value(draft.priority.name),
            tags: Value(_encodeTags(draft.tags)),
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
            tags: Value(_encodeTags(draft.tags)),
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
  Stream<List<String>> watchQuickTags() {
    return _orderedQuickTagsSelect().watch().map(_mapQuickTagRows);
  }

  @override
  Future<List<String>> listQuickTags() async {
    final rows = await _orderedQuickTagsSelect().get();
    return _mapQuickTagRows(rows);
  }

  @override
  Future<void> addQuickTag(String tag) async {
    final cleaned = _cleanTag(tag);
    await _database
        .into(_database.quickTagEntries)
        .insert(
          QuickTagEntriesCompanion.insert(name: cleaned, createdAt: _now()),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> deleteQuickTag(String tag) async {
    final cleaned = _cleanTag(tag);
    await (_database.delete(
      _database.quickTagEntries,
    )..where((entry) => entry.name.equals(cleaned))).go();
  }

  @override
  Future<void> close() => _database.close();

  SimpleSelectStatement<$DeadlineEntriesTable, DeadlineRow> _orderedSelect() {
    return _database.select(_database.deadlineEntries)..orderBy([
      (entry) => OrderingTerm.asc(entry.isCompleted),
      (entry) => OrderingTerm.asc(entry.createdAt),
    ]);
  }

  SimpleSelectStatement<$QuickTagEntriesTable, QuickTagRow>
  _orderedQuickTagsSelect() {
    return _database.select(_database.quickTagEntries)..orderBy([
      (entry) => OrderingTerm.asc(entry.createdAt),
      (entry) => OrderingTerm.asc(entry.name),
    ]);
  }

  List<Deadline> _mapRows(List<DeadlineRow> rows) {
    return sortDeadlines(rows.map(_mapRow));
  }

  List<String> _mapQuickTagRows(List<QuickTagRow> rows) {
    return rows.map((row) => row.name).toList(growable: false);
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
      tags: _decodeTags(row.tags),
    );
  }

  String _cleanTitle(String title) {
    final cleaned = title.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty.');
    }
    return cleaned;
  }

  String _cleanTag(String tag) {
    final cleaned = tag.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(tag, 'tag', 'Tag cannot be empty.');
    }
    return cleaned;
  }

  String _encodeTags(Iterable<String> tags) {
    return jsonEncode(normalizeDeadlineTags(tags));
  }

  List<String> _decodeTags(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw FormatException('Deadline tags must be a JSON array.', encoded);
    }

    final tags = <String>[];
    for (final item in decoded) {
      if (item is! String) {
        throw FormatException('Deadline tags must contain only strings.', item);
      }
      tags.add(item);
    }

    return normalizeDeadlineTags(tags);
  }
}
