import 'dart:async';

import '../domain/deadline.dart';
import '../domain/deadline_repository.dart';

class InMemoryDeadlineRepository implements DeadlineRepository {
  InMemoryDeadlineRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final List<Deadline> _deadlines = [];
  final List<String> _quickTags = [];
  final StreamController<List<Deadline>> _changes =
      StreamController<List<Deadline>>.broadcast();
  final StreamController<List<String>> _quickTagChanges =
      StreamController<List<String>>.broadcast();
  final DateTime Function() _now;

  int _nextId = 1;

  @override
  Stream<List<Deadline>> watchDeadlines() async* {
    yield await listDeadlines();
    yield* _changes.stream;
  }

  @override
  Future<List<Deadline>> listDeadlines() async {
    return sortDeadlines(_deadlines);
  }

  @override
  Future<int> createDeadline(DeadlineDraft draft) async {
    final now = _now();
    final deadline = Deadline(
      id: _nextId++,
      title: _cleanTitle(draft.title),
      dueAt: draft.dueAt,
      notes: draft.notes.trim(),
      priority: draft.priority,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      tags: normalizeDeadlineTags(draft.tags),
    );
    _deadlines.add(deadline);
    await _emit();
    return deadline.id;
  }

  @override
  Future<void> updateDeadline(int id, DeadlineDraft draft) async {
    final index = _findIndex(id);
    _deadlines[index] = _deadlines[index].copyWith(
      title: _cleanTitle(draft.title),
      dueAt: draft.dueAt,
      clearDueAt: draft.dueAt == null,
      notes: draft.notes.trim(),
      priority: draft.priority,
      updatedAt: _now(),
      tags: normalizeDeadlineTags(draft.tags),
    );
    await _emit();
  }

  @override
  Future<void> deleteDeadline(int id) async {
    final index = _findIndex(id);
    _deadlines.removeAt(index);
    await _emit();
  }

  @override
  Future<void> toggleCompleted(int id, bool isCompleted) async {
    final index = _findIndex(id);
    _deadlines[index] = _deadlines[index].copyWith(
      isCompleted: isCompleted,
      updatedAt: _now(),
    );
    await _emit();
  }

  @override
  Stream<List<String>> watchQuickTags() async* {
    yield await listQuickTags();
    yield* _quickTagChanges.stream;
  }

  @override
  Future<List<String>> listQuickTags() async {
    return List.unmodifiable(_quickTags);
  }

  @override
  Future<void> addQuickTag(String tag) async {
    final cleaned = _cleanTag(tag);
    if (!_quickTags.contains(cleaned)) {
      _quickTags.add(cleaned);
      await _emitQuickTags();
    }
  }

  @override
  Future<void> deleteQuickTag(String tag) async {
    final cleaned = _cleanTag(tag);
    final wasRemoved = _quickTags.remove(cleaned);
    if (wasRemoved) {
      await _emitQuickTags();
    }
  }

  @override
  Future<void> close() async {
    await _changes.close();
    await _quickTagChanges.close();
  }

  int _findIndex(int id) {
    final index = _deadlines.indexWhere((deadline) => deadline.id == id);
    if (index == -1) {
      throw StateError('Deadline $id was not found.');
    }
    return index;
  }

  Future<void> _emit() async {
    if (!_changes.isClosed) {
      _changes.add(await listDeadlines());
    }
  }

  Future<void> _emitQuickTags() async {
    if (!_quickTagChanges.isClosed) {
      _quickTagChanges.add(await listQuickTags());
    }
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
}
