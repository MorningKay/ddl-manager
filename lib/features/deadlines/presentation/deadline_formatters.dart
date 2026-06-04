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
  if (deadline.isCompleted) {
    return language == AppLanguage.zh ? '已完成' : 'Completed';
  }

  final dueAt = deadline.dueAt;
  if (dueAt == null) {
    return language == AppLanguage.zh ? '日期未公布' : 'Date TBA';
  }

  final difference = dueAt.difference(now);
  final isOverdue = difference.isNegative;
  final duration = isOverdue ? now.difference(dueAt) : difference;
  final amount = _formatDetailedDuration(duration, language);

  if (language == AppLanguage.zh) {
    return '${isOverdue ? '已截止' : '剩余'} $amount';
  }

  return isOverdue ? 'Closed $amount ago' : '$amount left';
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
