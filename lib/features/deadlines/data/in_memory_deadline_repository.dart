import 'dart:async';

import '../domain/deadline.dart';
import '../domain/deadline_repository.dart';

class InMemoryDeadlineRepository implements DeadlineRepository {
  InMemoryDeadlineRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final List<Deadline> _deadlines = [];
  final StreamController<List<Deadline>> _changes =
      StreamController<List<Deadline>>.broadcast();
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
  Future<void> close() async {
    await _changes.close();
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

  String _cleanTitle(String title) {
    final cleaned = title.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty.');
    }
    return cleaned;
  }
}
