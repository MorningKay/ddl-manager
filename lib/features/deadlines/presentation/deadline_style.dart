import 'package:flutter/material.dart';

import '../domain/deadline.dart';

Color priorityColor(DeadlinePriority priority, ColorScheme colorScheme) {
  return switch (priority) {
    DeadlinePriority.low => const Color(0xFF047857),
    DeadlinePriority.medium => const Color(0xFFB45309),
    DeadlinePriority.high => colorScheme.error,
  };
}

Color remainingTimeColor(
  Deadline deadline,
  DateTime now,
  ColorScheme colorScheme,
) {
  if (deadline.isCompleted) {
    return colorScheme.outline;
  }

  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return colorScheme.tertiary;
  }

  final difference = dueAt.difference(now);
  if (difference.isNegative) {
    return colorScheme.error;
  }

  if (difference <= const Duration(hours: 24)) {
    return const Color(0xFFB45309);
  }

  return colorScheme.primary;
}

IconData remainingTimeIcon(Deadline deadline, DateTime now) {
  if (deadline.isCompleted) {
    return Icons.task_alt;
  }

  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return Icons.event_busy;
  }

  final difference = dueAt.difference(now);
  if (difference.isNegative) {
    return Icons.warning_amber;
  }

  if (difference <= const Duration(hours: 24)) {
    return Icons.alarm;
  }

  return Icons.schedule;
}

double deadlineCountdownProgress(Deadline deadline, DateTime now) {
  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return 0;
  }

  if (!dueAt.isAfter(now)) {
    return 1;
  }

  const visibleWindow = Duration(days: 90);
  final remainingMinutes = dueAt.difference(now).inMinutes;
  final windowMinutes = visibleWindow.inMinutes;
  return (1 - remainingMinutes / windowMinutes).clamp(0, 1).toDouble();
}
