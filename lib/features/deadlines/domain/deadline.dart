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
  });

  final String title;
  final DateTime dueAt;
  final String notes;
  final DeadlinePriority priority;
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
  });

  final int id;
  final String title;
  final DateTime dueAt;
  final String notes;
  final DeadlinePriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deadline copyWith({
    int? id,
    String? title,
    DateTime? dueAt,
    String? notes,
    DeadlinePriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

List<Deadline> sortDeadlines(Iterable<Deadline> deadlines) {
  final sorted = deadlines.toList();
  sorted.sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    final dueComparison = a.dueAt.compareTo(b.dueAt);
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
