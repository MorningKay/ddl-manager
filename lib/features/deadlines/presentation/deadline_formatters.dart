import '../domain/deadline.dart';

String formatDueAt(DateTime dueAt) {
  return '${_twoDigits(dueAt.month)}/${_twoDigits(dueAt.day)} '
      '${_twoDigits(dueAt.hour)}:${_twoDigits(dueAt.minute)}';
}

String formatPriority(DeadlinePriority priority) {
  return priority.label;
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
