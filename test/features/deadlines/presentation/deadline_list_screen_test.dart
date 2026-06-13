import 'package:ddl_manager/app/ddl_manager_app.dart';
import 'package:ddl_manager/features/deadlines/application/deadline_providers.dart';
import 'package:ddl_manager/features/deadlines/data/in_memory_deadline_repository.dart';
import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:ddl_manager/features/deadlines/presentation/deadline_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a Chinese empty state by default', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('还没有 Deadline'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);
    expect(find.text('已截止'), findsOneWidget);
  });

  testWidgets('switches the visible language in settings', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('No deadlines yet'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('adds a deadline from the bottom sheet', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('添加 Deadline'));
    await tester.pumpAndSettle();

    expect(find.text('小时'), findsOneWidget);
    expect(find.text('分钟'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Math homework');
    await _tapSave(tester);

    expect(find.text('Math homework'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);
  });

  testWidgets('adds tags from the bottom sheet and shows them on the card', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('添加 Deadline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Tagged task');
    await tester.enterText(find.widgetWithText(TextFormField, '输入标签'), '作业');
    await tester.tap(find.byTooltip('添加标签'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '输入标签'), '考试');
    await tester.tap(find.byTooltip('添加标签'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    final deadlines = await repository.listDeadlines();
    expect(deadlines.single.tags, ['作业', '考试']);
    expect(find.text('Tagged task'), findsOneWidget);
    expect(find.text('作业'), findsAtLeastNWidgets(1));
    expect(find.text('考试'), findsAtLeastNWidgets(1));
  });

  testWidgets('starts with no quick tags and lets users edit them', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('添加 Deadline'));
    await tester.pumpAndSettle();

    expect(find.text('快捷标签'), findsNothing);
    expect(find.widgetWithText(InputChip, '作业'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'Tagged task');
    await tester.enterText(find.widgetWithText(TextFormField, '输入标签'), '夏令营');
    await tester.tap(find.byTooltip('添加标签'));
    await tester.pumpAndSettle();

    expect(await repository.listQuickTags(), ['夏令营']);
    expect(find.text('快捷标签'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '夏令营'), findsNWidgets(2));

    await tester.tap(find.byTooltip('删除快捷标签'));
    await tester.pumpAndSettle();
    expect(await repository.listQuickTags(), isEmpty);
    expect(find.widgetWithText(InputChip, '夏令营'), findsOneWidget);

    await _tapSave(tester);

    final deadlines = await repository.listDeadlines();
    expect(deadlines.single.tags, ['夏令营']);
  });

  testWidgets('saves an unsubmitted tag input as a quick tag', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('添加 Deadline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Direct save tag');
    await tester.enterText(find.widgetWithText(TextFormField, '输入标签'), '考试');
    await _tapSave(tester);

    final deadlines = await repository.listDeadlines();
    expect(deadlines.single.tags, ['考试']);
    expect(await repository.listQuickTags(), ['考试']);
  });

  testWidgets('filters deadlines by all selected tags', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    final now = DateTime(2026, 6, 4, 12);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Required exam',
        dueAt: now.add(const Duration(days: 1)),
        notes: '',
        priority: DeadlinePriority.high,
        tags: ['必修课', '考试'],
      ),
    );
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Summer camp',
        dueAt: now.add(const Duration(days: 2)),
        notes: '',
        priority: DeadlinePriority.medium,
        tags: ['科学院', '夏令营'],
      ),
    );
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Standalone exam',
        dueAt: now.add(const Duration(days: 3)),
        notes: '',
        priority: DeadlinePriority.low,
        tags: ['考试'],
      ),
    );

    await tester.pumpWidget(_testApp(repository, nowFactory: () => now));
    await tester.pump();

    expect(find.text('Required exam'), findsOneWidget);
    expect(find.text('Summer camp'), findsOneWidget);
    expect(find.text('Standalone exam'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, '考试').first);
    await tester.pumpAndSettle();

    expect(find.text('Required exam'), findsOneWidget);
    expect(find.text('Standalone exam'), findsOneWidget);
    expect(find.text('Summer camp'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, '必修课').first);
    await tester.pumpAndSettle();

    expect(find.text('Required exam'), findsOneWidget);
    expect(find.text('Standalone exam'), findsNothing);
    expect(find.text('Summer camp'), findsNothing);

    await tester.tap(find.byTooltip('展开标签').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('收起标签'), findsWidgets);

    await tester.tap(find.widgetWithText(FilterChip, '全部').first);
    await tester.pumpAndSettle();

    expect(find.text('Required exam'), findsOneWidget);
    expect(find.text('Summer camp'), findsOneWidget);
    expect(find.text('Standalone exam'), findsOneWidget);
  });

  testWidgets('keeps the collapsed tag expand button pinned right', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    final now = DateTime(2026, 6, 4, 12);

    for (var index = 0; index < 12; index += 1) {
      await repository.createDeadline(
        DeadlineDraft(
          title: 'Tagged task $index',
          dueAt: now.add(Duration(days: index + 1)),
          notes: '',
          priority: DeadlinePriority.medium,
          tags: ['标签$index'],
        ),
      );
    }

    await tester.pumpWidget(_testApp(repository, nowFactory: () => now));
    await tester.pump();

    final expandButton = find.byTooltip('展开标签');
    expect(expandButton, findsOneWidget);

    final scaffoldWidth = tester.getSize(find.byType(Scaffold)).width;
    final buttonRight = tester.getTopRight(expandButton).dx;
    expect(buttonRight, greaterThan(scaffoldWidth - 80));
  });

  testWidgets('adds a deadline with unannounced date', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('添加 Deadline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Contest result');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(find.text('Contest result'), findsOneWidget);
    expect(find.text('日期未公布'), findsAtLeastNWidgets(1));
    expect(find.text('—'), findsOneWidget);
    expect(find.text('按加入顺序排列'), findsNothing);
    expect(find.text('可先保存，公布日期后再补充具体时间。'), findsNothing);
  });

  testWidgets('shows detailed remaining time without priority text badges', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Submit scholarship',
        dueAt: DateTime.now().add(const Duration(hours: 2)),
        notes: '',
        priority: DeadlinePriority.high,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('Submit scholarship'), findsOneWidget);
    expect(find.text('高优先级'), findsNothing);
    expect(find.textContaining('剩余'), findsOneWidget);
    expect(find.text('时间进度'), findsNothing);
    expect(find.textContaining('截止时间:'), findsNothing);
  });

  testWidgets('refreshes countdown text while the screen stays open', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    var now = DateTime(2026, 6, 4, 12);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Live countdown',
        dueAt: now.add(const Duration(minutes: 3)),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    await tester.pumpWidget(_testApp(repository, nowFactory: () => now));
    await tester.pump();
    final initialCountdown = _singleRemainingText(tester);

    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(minutes: 1));
    final updatedCountdown = _singleRemainingText(tester);

    expect(initialCountdown, '剩余 3分钟');
    expect(updatedCountdown, '剩余 1分钟');
  });

  testWidgets('shows overdue deadlines on the closed tab', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    final now = DateTime.now();
    final dueAt = now.subtract(const Duration(hours: 3));
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Expired form',
        dueAt: dueAt,
        notes: '',
        priority: DeadlinePriority.high,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();
    await tester.tap(find.text('已截止').first);
    await tester.pumpAndSettle();

    expect(find.text('Expired form'), findsOneWidget);
    expect(
      find.text('已截止 · ${_formatZhDateMarker(dueAt, now)}'),
      findsOneWidget,
    );
  });

  testWidgets('opens the editor and updates a deadline', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Draft essay',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.text('Draft essay'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Final essay');
    await _tapSave(tester);

    expect(find.text('Draft essay'), findsNothing);
    expect(find.text('Final essay'), findsOneWidget);
  });

  testWidgets('toggles a deadline into the completed section', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Read chapter',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('已完成'), findsAtLeastNWidgets(1));
    expect(find.textContaining('剩余'), findsOneWidget);
    expect(find.text('Read chapter'), findsOneWidget);
  });

  testWidgets('shows completed dated items before unannounced dates', (
    tester,
  ) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    final completedId = await repository.createDeadline(
      DeadlineDraft(
        title: 'Completed dated',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        notes: '',
        priority: DeadlinePriority.medium,
      ),
    );
    await repository.toggleCompleted(completedId, true);
    await repository.createDeadline(
      const DeadlineDraft(
        title: 'TBA item',
        dueAt: null,
        notes: '',
        priority: DeadlinePriority.low,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    final completedTop = tester.getTopLeft(find.text('Completed dated')).dy;
    final tbaTop = tester.getTopLeft(find.text('TBA item')).dy;

    expect(completedTop, lessThan(tbaTop));
  });
}

Widget _testApp(
  InMemoryDeadlineRepository repository, {
  DateTime Function()? nowFactory,
}) {
  return ProviderScope(
    overrides: [
      deadlineRepositoryProvider.overrideWithValue(repository),
      if (nowFactory != null) deadlineNowProvider.overrideWithValue(nowFactory),
    ],
    child: const DDLManagerApp(),
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, '保存');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

String _formatZhDateMarker(DateTime dueAt, DateTime now) {
  final date = dueAt.year == now.year
      ? '${_twoDigits(dueAt.month)}月${_twoDigits(dueAt.day)}日'
      : '${dueAt.year}年${_twoDigits(dueAt.month)}月${_twoDigits(dueAt.day)}日';
  return '$date '
      '${_twoDigits(dueAt.hour)}:${_twoDigits(dueAt.minute)}';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}

String _singleRemainingText(WidgetTester tester) {
  final finder = find.byWidgetPredicate((widget) {
    return widget is Text && widget.data?.startsWith('剩余 ') == true;
  });
  expect(finder, findsOneWidget);
  return tester.widget<Text>(finder).data!;
}
