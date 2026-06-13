import '../domain/deadline.dart';

class DeadlineBoard {
  const DeadlineBoard({required this.inProgress, required this.closed});

  final DeadlineBoardColumn inProgress;
  final DeadlineBoardColumn closed;
}

class DeadlineBoardColumn {
  const DeadlineBoardColumn({
    required this.kind,
    required this.scheduled,
    required this.dateUnannounced,
    required this.completed,
  });

  final DeadlineBoardKind kind;
  final List<Deadline> scheduled;
  final List<Deadline> dateUnannounced;
  final List<Deadline> completed;

  bool get isEmpty =>
      scheduled.isEmpty && dateUnannounced.isEmpty && completed.isEmpty;

  int get activeCount => scheduled.length + dateUnannounced.length;

  int get totalCount => activeCount + completed.length;
}

enum DeadlineBoardKind { inProgress, closed }

DeadlineBoard buildDeadlineBoard(List<Deadline> deadlines, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final inProgressScheduled = <Deadline>[];
  final inProgressDateUnannounced = <Deadline>[];
  final inProgressCompleted = <Deadline>[];
  final closedScheduled = <Deadline>[];
  final closedCompleted = <Deadline>[];

  for (final deadline in deadlines) {
    final dueAt = deadline.dueAt;
    final isClosed = dueAt != null && dueAt.isBefore(reference);

    if (isClosed) {
      if (deadline.isCompleted) {
        closedCompleted.add(deadline);
      } else {
        closedScheduled.add(deadline);
      }
      continue;
    }

    if (deadline.isCompleted) {
      inProgressCompleted.add(deadline);
    } else if (dueAt == null) {
      inProgressDateUnannounced.add(deadline);
    } else {
      inProgressScheduled.add(deadline);
    }
  }

  inProgressScheduled.sort(_compareByDueAt);
  closedScheduled.sort(_compareByDueAt);
  inProgressDateUnannounced.sort(_compareByCreatedAt);
  inProgressCompleted.sort(_compareCompleted);
  closedCompleted.sort(_compareCompleted);

  return DeadlineBoard(
    inProgress: DeadlineBoardColumn(
      kind: DeadlineBoardKind.inProgress,
      scheduled: inProgressScheduled,
      dateUnannounced: inProgressDateUnannounced,
      completed: inProgressCompleted,
    ),
    closed: DeadlineBoardColumn(
      kind: DeadlineBoardKind.closed,
      scheduled: closedScheduled,
      dateUnannounced: const [],
      completed: closedCompleted,
    ),
  );
}

int _compareByDueAt(Deadline a, Deadline b) {
  final aDueAt = a.dueAt;
  final bDueAt = b.dueAt;
  if (aDueAt == null || bDueAt == null) {
    if (aDueAt != bDueAt) {
      return aDueAt == null ? 1 : -1;
    }

    return _compareByCreatedAt(a, b);
  }

  final dueComparison = aDueAt.compareTo(bDueAt);
  if (dueComparison != 0) {
    return dueComparison;
  }

  return _compareByCreatedAt(a, b);
}

int _compareCompleted(Deadline a, Deadline b) {
  final dueComparison = _compareByDueAt(a, b);
  if (dueComparison != 0) {
    return dueComparison;
  }

  return a.updatedAt.compareTo(b.updatedAt);
}

int _compareByCreatedAt(Deadline a, Deadline b) {
  return a.createdAt.compareTo(b.createdAt);
}

DeadlineBoardColumn filterDeadlineBoardColumnByTags(
  DeadlineBoardColumn column,
  Set<String> selectedTags,
) {
  if (selectedTags.isEmpty) {
    return column;
  }

  return DeadlineBoardColumn(
    kind: column.kind,
    scheduled: _filterByTags(column.scheduled, selectedTags),
    dateUnannounced: _filterByTags(column.dateUnannounced, selectedTags),
    completed: _filterByTags(column.completed, selectedTags),
  );
}

List<String> deadlineTagOptions(Iterable<Deadline> deadlines) {
  final counts = <String, int>{};
  for (final deadline in deadlines) {
    for (final tag in deadline.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }

  final tags = counts.keys.toList();
  tags.sort((a, b) {
    final countComparison = counts[b]!.compareTo(counts[a]!);
    if (countComparison != 0) {
      return countComparison;
    }

    return a.compareTo(b);
  });
  return tags;
}

List<Deadline> _filterByTags(
  List<Deadline> deadlines,
  Set<String> selectedTags,
) {
  return deadlines
      .where((deadline) => _containsAllTags(deadline, selectedTags))
      .toList(growable: false);
}

bool _containsAllTags(Deadline deadline, Set<String> selectedTags) {
  final tags = deadline.tags.toSet();
  return selectedTags.every(tags.contains);
}
