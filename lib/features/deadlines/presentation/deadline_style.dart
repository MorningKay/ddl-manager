import 'package:flutter/material.dart';

import '../domain/deadline.dart';

const _minimumProgressWindow = Duration(days: 7);
const _maximumProgressWindow = Duration(days: 365);
const _targetRemainingNumerator = 7;
const _targetRemainingDenominator = 10;
const _outlierResistantItemCount = 4;

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

Duration deadlineProgressWindow(Iterable<Deadline> deadlines, DateTime now) {
  final remainingSeconds = <int>[];
  for (final deadline in deadlines) {
    final dueAt = deadline.dueAt;
    if (dueAt == null || !dueAt.isAfter(now)) {
      continue;
    }

    remainingSeconds.add(dueAt.difference(now).inSeconds);
  }

  if (remainingSeconds.isEmpty) {
    return const Duration(days: 90);
  }

  remainingSeconds.sort();
  final typicalMaxSeconds = _typicalMaxRemainingSeconds(remainingSeconds);
  final targetWindowSeconds =
      (typicalMaxSeconds * _targetRemainingDenominator +
          _targetRemainingNumerator -
          1) ~/
      _targetRemainingNumerator;
  final boundedWindowSeconds = targetWindowSeconds
      .clamp(_minimumProgressWindow.inSeconds, _maximumProgressWindow.inSeconds)
      .toInt();

  return Duration(seconds: boundedWindowSeconds);
}

double deadlineCountdownProgress(
  Deadline deadline,
  DateTime now, {
  Duration? visibleWindow,
}) {
  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return 0;
  }

  if (!dueAt.isAfter(now)) {
    return 1;
  }

  final window = visibleWindow ?? deadlineProgressWindow([deadline], now);
  final windowSeconds = window.inSeconds;
  if (windowSeconds <= 0) {
    return 0;
  }

  final remainingSeconds = dueAt.difference(now).inSeconds;
  return (1 - remainingSeconds / windowSeconds).clamp(0, 1).toDouble();
}

int _typicalMaxRemainingSeconds(List<int> sortedRemainingSeconds) {
  if (sortedRemainingSeconds.length < _outlierResistantItemCount) {
    return sortedRemainingSeconds.last;
  }

  final percentileIndex = ((sortedRemainingSeconds.length - 1) * 0.9).floor();
  return sortedRemainingSeconds[percentileIndex];
}
