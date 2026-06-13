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
  String get tags => _isZh ? '标签' : 'Tags';
  String get tagInput => _isZh ? '输入标签' : 'Add a tag';
  String get addTag => _isZh ? '添加标签' : 'Add tag';
  String get quickTags => _isZh ? '快捷标签' : 'Quick tags';
  String get deleteQuickTag => _isZh ? '删除快捷标签' : 'Delete quick tag';
  String get allTags => _isZh ? '全部' : 'All';
  String get expandTags => _isZh ? '展开标签' : 'Expand tags';
  String get collapseTags => _isZh ? '收起标签' : 'Collapse tags';
  String get dueTime => _isZh ? 'Deadline 时间' : 'Due time';
  String get dateKnown => _isZh ? '日期已公布' : 'Date announced';
  String get dateUnannounced => _isZh ? '日期未公布' : 'Date TBA';
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
  String get noMatchingTagsTitle =>
      _isZh ? '没有匹配标签的 Deadline' : 'No matching deadlines';
  String get noMatchingTagsBody =>
      _isZh ? '调整标签筛选后再看看。' : 'Adjust the tag filters and try again.';
  String get exactDeadline => _isZh ? '截止时间' : 'Deadline';
  String get progress => _isZh ? '时间进度' : 'Time progress';

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

  String boardTitle(DeadlineBoardKind kind) {
    return switch (kind) {
      DeadlineBoardKind.inProgress => inProgress,
      DeadlineBoardKind.closed => closed,
    };
  }
}
