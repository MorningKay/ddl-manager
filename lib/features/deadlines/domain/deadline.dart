enum DeadlinePriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const DeadlinePriority(this.label);

  final String label;
}

class DeadlineDraft {
  const DeadlineDraft({
    required this.title,
    required this.dueAt,
    required this.notes,
    required this.priority,
    this.tags = const [],
  });

  final String title;
  final DateTime? dueAt;
  final String notes;
  final DeadlinePriority priority;
  final List<String> tags;
}

class Deadline {
  const Deadline({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.notes,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  final int id;
  final String title;
  final DateTime? dueAt;
  final String notes;
  final DeadlinePriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  Deadline copyWith({
    int? id,
    String? title,
    DateTime? dueAt,
    bool clearDueAt = false,
    String? notes,
    DeadlinePriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: clearDueAt ? null : dueAt ?? this.dueAt,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

List<Deadline> sortDeadlines(Iterable<Deadline> deadlines) {
  final sorted = deadlines.toList();
  sorted.sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    final aDueAt = a.dueAt;
    final bDueAt = b.dueAt;
    if (aDueAt == null || bDueAt == null) {
      if (aDueAt != bDueAt) {
        return aDueAt == null ? 1 : -1;
      }

      return a.createdAt.compareTo(b.createdAt);
    }

    final dueComparison = aDueAt.compareTo(bDueAt);
    if (dueComparison != 0) {
      return dueComparison;
    }

    return a.createdAt.compareTo(b.createdAt);
  });
  return sorted;
}

DeadlinePriority parseDeadlinePriority(String value) {
  return DeadlinePriority.values.firstWhere(
    (priority) => priority.name == value,
    orElse: () => DeadlinePriority.medium,
  );
}

List<String> normalizeDeadlineTags(Iterable<String> tags) {
  final seen = <String>{};
  final normalized = <String>[];

  for (final tag in tags) {
    final cleaned = tag.trim();
    if (cleaned.isEmpty || seen.contains(cleaned)) {
      continue;
    }

    seen.add(cleaned);
    normalized.add(cleaned);
  }

  return List.unmodifiable(normalized);
}
