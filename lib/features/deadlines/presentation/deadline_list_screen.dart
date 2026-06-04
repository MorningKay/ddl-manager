import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/deadline_providers.dart';
import '../domain/deadline.dart';
import 'deadline_form_sheet.dart';
import 'deadline_formatters.dart';
import 'deadline_sections.dart';

class DeadlineListScreen extends ConsumerWidget {
  const DeadlineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlines = ref.watch(deadlinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('DDLManager')),
      body: deadlines.when(
        data: (items) => _DeadlineList(deadlines: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add deadline',
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, {Deadline? deadline}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DeadlineFormSheet(deadline: deadline),
    );
  }
}

class _DeadlineList extends StatelessWidget {
  const _DeadlineList({required this.deadlines});

  final List<Deadline> deadlines;

  @override
  Widget build(BuildContext context) {
    if (deadlines.isEmpty) {
      return const _EmptyState();
    }

    final sections = buildDeadlineSections(deadlines);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final section = sections[index];
        return _DeadlineSectionView(section: section);
      },
    );
  }
}

class _DeadlineSectionView extends StatelessWidget {
  const _DeadlineSectionView({required this.section});

  final DeadlineSection section;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (final (index, deadline) in section.deadlines.indexed) ...[
                  _DeadlineTile(deadline: deadline),
                  if (index != section.deadlines.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineTile extends ConsumerWidget {
  const _DeadlineTile({required this.deadline});

  final Deadline deadline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: deadline.isCompleted,
        onChanged: (value) {
          ref
              .read(deadlineRepositoryProvider)
              .toggleCompleted(deadline.id, value ?? false);
        },
      ),
      title: Text(
        deadline.title,
        style: deadline.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        '${formatDueAt(deadline.dueAt)} · ${formatPriority(deadline.priority)}'
        '${deadline.notes.isEmpty ? '' : ' · ${deadline.notes}'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _showForm(context, deadline),
      trailing: PopupMenuButton<_DeadlineAction>(
        tooltip: 'Deadline actions',
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (context) => const [
          PopupMenuItem(value: _DeadlineAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _DeadlineAction.delete, child: Text('Delete')),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, Deadline deadline) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DeadlineFormSheet(deadline: deadline),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _DeadlineAction action,
  ) async {
    switch (action) {
      case _DeadlineAction.edit:
        _showForm(context, deadline);
      case _DeadlineAction.delete:
        await ref.read(deadlineRepositoryProvider).deleteDeadline(deadline.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No deadlines yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first deadline to start tracking work.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load deadlines: $error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

enum _DeadlineAction { edit, delete }
