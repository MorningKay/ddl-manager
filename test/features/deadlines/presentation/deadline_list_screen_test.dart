import 'package:ddl_manager/app/ddl_manager_app.dart';
import 'package:ddl_manager/features/deadlines/application/deadline_providers.dart';
import 'package:ddl_manager/features/deadlines/data/in_memory_deadline_repository.dart';
import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
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
    expect(find.text('按加入顺序排列'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows priority color labels and detailed remaining time', (
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
    expect(find.text('高优先级'), findsOneWidget);
    expect(find.textContaining('剩余'), findsOneWidget);
    expect(find.text('时间进度'), findsNothing);
    expect(find.textContaining('截止时间:'), findsNothing);
  });

  testWidgets('shows overdue deadlines on the closed tab', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);
    await repository.createDeadline(
      DeadlineDraft(
        title: 'Expired form',
        dueAt: DateTime.now().subtract(const Duration(hours: 3)),
        notes: '',
        priority: DeadlinePriority.high,
      ),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();
    await tester.tap(find.text('已截止').first);
    await tester.pumpAndSettle();

    expect(find.text('Expired form'), findsOneWidget);
    expect(find.textContaining('已截止'), findsAtLeastNWidgets(1));
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
    expect(find.text('Read chapter'), findsOneWidget);
  });
}

Widget _testApp(InMemoryDeadlineRepository repository) {
  return ProviderScope(
    overrides: [deadlineRepositoryProvider.overrideWithValue(repository)],
    child: const DDLManagerApp(),
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, '保存');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}
