import 'package:ddl_manager/app/ddl_manager_app.dart';
import 'package:ddl_manager/features/deadlines/application/deadline_providers.dart';
import 'package:ddl_manager/features/deadlines/data/in_memory_deadline_repository.dart';
import 'package:ddl_manager/features/deadlines/domain/deadline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an empty state', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('No deadlines yet'), findsOneWidget);
  });

  testWidgets('adds a deadline from the bottom sheet', (tester) async {
    final repository = InMemoryDeadlineRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    await tester.tap(find.byTooltip('Add deadline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Math homework');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Math homework'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
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
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

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

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Read chapter'), findsOneWidget);
  });
}

Widget _testApp(InMemoryDeadlineRepository repository) {
  return ProviderScope(
    overrides: [deadlineRepositoryProvider.overrideWithValue(repository)],
    child: const DDLManagerApp(),
  );
}
