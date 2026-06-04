import '../domain/deadline.dart';

class DeadlineSection {
  const DeadlineSection({required this.title, required this.deadlines});

  final String title;
  final List<Deadline> deadlines;
}

List<DeadlineSection> buildDeadlineSections(
  List<Deadline> deadlines, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final tomorrow = today.add(const Duration(days: 1));

  final overdue = <Deadline>[];
  final todayItems = <Deadline>[];
  final upcoming = <Deadline>[];
  final completed = <Deadline>[];

  for (final deadline in deadlines) {
    if (deadline.isCompleted) {
      completed.add(deadline);
    } else if (deadline.dueAt.isBefore(today)) {
      overdue.add(deadline);
    } else if (deadline.dueAt.isBefore(tomorrow)) {
      todayItems.add(deadline);
    } else {
      upcoming.add(deadline);
    }
  }

  return [
    DeadlineSection(title: 'Overdue', deadlines: overdue),
    DeadlineSection(title: 'Today', deadlines: todayItems),
    DeadlineSection(title: 'Upcoming', deadlines: upcoming),
    DeadlineSection(title: 'Completed', deadlines: completed),
  ].where((section) => section.deadlines.isNotEmpty).toList(growable: false);
}
