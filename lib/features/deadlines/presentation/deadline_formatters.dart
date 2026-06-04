import '../../../app/app_language.dart';
import '../domain/deadline.dart';

String formatDueAt(DateTime dueAt, AppLanguage language) {
  if (language == AppLanguage.zh) {
    return '${dueAt.year}年${_twoDigits(dueAt.month)}月'
        '${_twoDigits(dueAt.day)}日 ${_twoDigits(dueAt.hour)}:'
        '${_twoDigits(dueAt.minute)}';
  }

  return '${_twoDigits(dueAt.month)}/${_twoDigits(dueAt.day)} '
      '${_twoDigits(dueAt.hour)}:${_twoDigits(dueAt.minute)}';
}

String formatDueDate(DateTime dueAt, AppLanguage language) {
  if (language == AppLanguage.zh) {
    return '${dueAt.year}年${_twoDigits(dueAt.month)}月'
        '${_twoDigits(dueAt.day)}日';
  }

  return '${_twoDigits(dueAt.month)}/${_twoDigits(dueAt.day)}';
}

String formatRemainingTime(
  Deadline deadline, {
  required DateTime now,
  required AppLanguage language,
}) {
  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return '—';
  }

  final difference = dueAt.difference(now);
  final isOverdue = difference.isNegative;
  if (isOverdue) {
    final marker = formatDueTimeMarker(dueAt, now: now, language: language);
    return language == AppLanguage.zh ? '已截止 · $marker' : 'Closed · $marker';
  }

  final amount = _formatDetailedDuration(difference, language);

  if (language == AppLanguage.zh) {
    return '剩余 $amount';
  }

  return '$amount left';
}

String formatDueTimeMarker(
  DateTime dueAt, {
  required DateTime now,
  required AppLanguage language,
}) {
  final shouldShowYear = dueAt.year != now.year;
  final month = _twoDigits(dueAt.month);
  final day = _twoDigits(dueAt.day);
  final hour = _twoDigits(dueAt.hour);
  final minute = _twoDigits(dueAt.minute);

  if (language == AppLanguage.zh) {
    final date = shouldShowYear ? '${dueAt.year}年$month月$day日' : '$month月$day日';
    return '$date $hour:$minute';
  }

  final date = shouldShowYear ? '${dueAt.year}/$month/$day' : '$month/$day';
  return '$date $hour:$minute';
}

String _formatDetailedDuration(Duration duration, AppLanguage language) {
  final totalMinutes = (duration.inSeconds / Duration.secondsPerMinute)
      .ceil()
      .clamp(1, 1 << 31);
  final days = totalMinutes ~/ Duration.minutesPerDay;
  final hours =
      (totalMinutes % Duration.minutesPerDay) ~/ Duration.minutesPerHour;
  final minutes = totalMinutes % Duration.minutesPerHour;

  if (language == AppLanguage.zh) {
    if (days > 0) {
      return '$days天$hours小时$minutes分钟';
    }

    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }

    return '$minutes分钟';
  }

  if (days > 0) {
    return '${days}d ${hours}h ${minutes}m';
  }

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  return '${minutes}m';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
