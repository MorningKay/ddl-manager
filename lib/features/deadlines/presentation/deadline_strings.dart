import '../../../app/app_language.dart';
import '../domain/deadline.dart';
import 'deadline_sections.dart';

class DeadlineStrings {
  const DeadlineStrings(this.language);

  final AppLanguage language;

  bool get _isZh => language == AppLanguage.zh;

  String get addDeadline => _isZh ? '添加 Deadline' : 'Add deadline';
  String get editDeadline => _isZh ? '编辑 Deadline' : 'Edit deadline';
  String get title => _isZh ? '标题' : 'Title';
  String get titleRequired => _isZh ? '标题不能为空' : 'Title is required';
  String get notes => _isZh ? '备注' : 'Notes';
  String get dueTime => _isZh ? 'Deadline 时间' : 'Due time';
  String get dateKnown => _isZh ? '日期已公布' : 'Date announced';
  String get dateUnannounced => _isZh ? '日期未公布' : 'Date TBA';
  String get dateUnannouncedHelp =>
      _isZh ? '可先保存，公布日期后再补充具体时间。' : 'Save now and add the exact date later.';
  String get hour => _isZh ? '小时' : 'Hour';
  String get minute => _isZh ? '分钟' : 'Minute';
  String get priority => _isZh ? '优先级' : 'Priority';
  String get save => _isZh ? '保存' : 'Save';
  String get settings => _isZh ? '设置' : 'Settings';
  String get languageLabel => _isZh ? '语言' : 'Language';
  String get chinese => '中文';
  String get english => 'English';
  String get deadlineActions => _isZh ? 'Deadline 操作' : 'Deadline actions';
  String get edit => _isZh ? '编辑' : 'Edit';
  String get delete => _isZh ? '删除' : 'Delete';
  String get noDeadlinesTitle => _isZh ? '还没有 Deadline' : 'No deadlines yet';
  String get noDeadlinesBody => _isZh
      ? '添加第一个 Deadline 来开始管理任务。'
      : 'Add your first deadline to start tracking work.';
  String get completed => _isZh ? '已完成' : 'Completed';
  String get inProgress => _isZh ? '进行中' : 'In progress';
  String get closed => _isZh ? '已截止' : 'Closed';
  String get noInProgressTitle =>
      _isZh ? '没有进行中的 Deadline' : 'No active deadlines';
  String get noClosedTitle => _isZh ? '没有已截止的 Deadline' : 'No closed deadlines';
  String get noInProgressBody =>
      _isZh ? '新的 Deadline 会出现在这里。' : 'New deadlines will show up here.';
  String get noClosedBody => _isZh
      ? '超过 Deadline 时间且未完成的项目会出现在这里。'
      : 'Deadlines past their due time will show up here.';
  String get exactDeadline => _isZh ? '截止时间' : 'Deadline';
  String get progress => _isZh ? '时间进度' : 'Time progress';
  String get addedOrder => _isZh ? '按加入顺序排列' : 'Ordered by creation time';

  String loadError(Object error) {
    return _isZh ? '无法加载 Deadline: $error' : 'Could not load deadlines: $error';
  }

  String saveError(Object error) {
    return _isZh ? '无法保存 Deadline: $error' : 'Could not save deadline: $error';
  }

  String priorityName(DeadlinePriority priority) {
    if (!_isZh) {
      return priority.label;
    }

    return switch (priority) {
      DeadlinePriority.low => '低',
      DeadlinePriority.medium => '中',
      DeadlinePriority.high => '高',
    };
  }

  String priorityBadge(DeadlinePriority priority) {
    final name = priorityName(priority);
    return _isZh ? '$name优先级' : '$name priority';
  }

  String boardTitle(DeadlineBoardKind kind) {
    return switch (kind) {
      DeadlineBoardKind.inProgress => inProgress,
      DeadlineBoardKind.closed => closed,
    };
  }
}
