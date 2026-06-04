import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_language.dart';
import '../application/deadline_providers.dart';
import '../domain/deadline.dart';
import 'deadline_form_sheet.dart';
import 'deadline_formatters.dart';
import 'deadline_sections.dart';
import 'deadline_strings.dart';
import 'deadline_style.dart';

class DeadlineListScreen extends ConsumerWidget {
  const DeadlineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final strings = DeadlineStrings(language);
    final deadlines = ref.watch(deadlinesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DDLManager'),
          actions: [
            IconButton(
              tooltip: strings.settings,
              onPressed: () => _showSettings(context),
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: strings.inProgress),
              Tab(text: strings.closed),
            ],
          ),
        ),
        body: deadlines.when(
          data: (items) => _DeadlineTabs(
            deadlines: items,
            language: language,
            strings: strings,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(error: error, strings: strings),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: strings.addDeadline,
          onPressed: () => _showForm(context),
          child: const Icon(Icons.add),
        ),
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

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _LanguageSettingsSheet(),
    );
  }
}

class _DeadlineTabs extends StatelessWidget {
  const _DeadlineTabs({
    required this.deadlines,
    required this.language,
    required this.strings,
  });

  final List<Deadline> deadlines;
  final AppLanguage language;
  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    if (deadlines.isEmpty) {
      return _EmptyState(strings: strings);
    }

    final board = buildDeadlineBoard(deadlines);

    return TabBarView(
      children: [
        _DeadlineBoardPage(
          column: board.inProgress,
          language: language,
          strings: strings,
        ),
        _DeadlineBoardPage(
          column: board.closed,
          language: language,
          strings: strings,
        ),
      ],
    );
  }
}

class _DeadlineBoardPage extends StatelessWidget {
  const _DeadlineBoardPage({
    required this.column,
    required this.language,
    required this.strings,
  });

  final DeadlineBoardColumn column;
  final AppLanguage language;
  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    if (column.isEmpty) {
      return _EmptyBoardState(kind: column.kind, strings: strings);
    }

    final now = DateTime.now();
    final progressWindow = deadlineProgressWindow([
      ...column.scheduled,
      ...column.completed,
    ], now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        if (column.scheduled.isNotEmpty)
          for (final deadline in column.scheduled) ...[
            _DeadlineCard(
              deadline: deadline,
              now: now,
              progressWindow: progressWindow,
              language: language,
              strings: strings,
            ),
            const SizedBox(height: 10),
          ],
        if (column.completed.isNotEmpty)
          for (final deadline in column.completed) ...[
            _DeadlineCard(
              deadline: deadline,
              now: now,
              progressWindow: progressWindow,
              language: language,
              strings: strings,
            ),
            const SizedBox(height: 10),
          ],
        if (column.dateUnannounced.isNotEmpty) ...[
          _DateUnannouncedHeader(strings: strings),
          const SizedBox(height: 8),
          for (final deadline in column.dateUnannounced) ...[
            _DeadlineCard(
              deadline: deadline,
              now: now,
              progressWindow: progressWindow,
              language: language,
              strings: strings,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _DateUnannouncedHeader extends StatelessWidget {
  const _DateUnannouncedHeader({required this.strings});

  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.event_busy, size: 18, color: colorScheme.tertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.dateUnannounced,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends ConsumerWidget {
  const _DeadlineCard({
    required this.deadline,
    required this.now,
    required this.progressWindow,
    required this.language,
    required this.strings,
  });

  final Deadline deadline;
  final DateTime now;
  final Duration progressWindow;
  final AppLanguage language;
  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityTone = priorityColor(deadline.priority, colorScheme);
    final statusTone = remainingTimeColor(deadline, now, colorScheme);
    final cardTone = deadline.isCompleted ? colorScheme.outline : priorityTone;

    return Opacity(
      opacity: deadline.isCompleted ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showForm(context, deadline),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cardTone.withValues(alpha: 0.065),
              border: Border.all(color: cardTone.withValues(alpha: 0.18)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: priorityTone.withValues(alpha: 0.78),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                    child: const SizedBox(width: 5),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: deadline.isCompleted,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) {
                                  ref
                                      .read(deadlineRepositoryProvider)
                                      .toggleCompleted(
                                        deadline.id,
                                        value ?? false,
                                      );
                                },
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deadline.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              decoration: deadline.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                      ),
                                      if (deadline.notes.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          deadline.notes,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              PopupMenuButton<_DeadlineAction>(
                                tooltip: strings.deadlineActions,
                                onSelected: (action) =>
                                    _handleAction(context, ref, action),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: _DeadlineAction.edit,
                                    child: Text(strings.edit),
                                  ),
                                  PopupMenuItem(
                                    value: _DeadlineAction.delete,
                                    child: Text(strings.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _CountdownTrack(
                            deadline: deadline,
                            now: now,
                            progressWindow: progressWindow,
                            language: language,
                            statusTone: statusTone,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _CountdownTrack extends StatelessWidget {
  const _CountdownTrack({
    required this.deadline,
    required this.now,
    required this.progressWindow,
    required this.language,
    required this.statusTone,
  });

  final Deadline deadline;
  final DateTime now;
  final Duration progressWindow;
  final AppLanguage language;
  final Color statusTone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = deadlineCountdownProgress(
      deadline,
      now,
      visibleWindow: progressWindow,
    );
    final countdown = formatRemainingTime(
      deadline,
      now: now,
      language: language,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(remainingTimeIcon(deadline, now), size: 15, color: statusTone),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                countdown,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: statusTone,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (deadline.isCompleted) ...[
              const SizedBox(width: 8),
              _CompletedBadge(label: DeadlineStrings(language).completed),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            color: statusTone,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LanguageSettingsSheet extends ConsumerWidget {
  const _LanguageSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final strings = DeadlineStrings(language);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.settings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              strings.languageLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AppLanguage>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AppLanguage.zh,
                  label: Text(strings.chinese),
                ),
                ButtonSegment(
                  value: AppLanguage.en,
                  label: Text(strings.english),
                ),
              ],
              selected: {language},
              onSelectionChanged: (selected) {
                ref
                    .read(appLanguageProvider.notifier)
                    .setLanguage(selected.single);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final DeadlineStrings strings;

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
              strings.noDeadlinesTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              strings.noDeadlinesBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBoardState extends StatelessWidget {
  const _EmptyBoardState({required this.kind, required this.strings});

  final DeadlineBoardKind kind;
  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    final title = switch (kind) {
      DeadlineBoardKind.inProgress => strings.noInProgressTitle,
      DeadlineBoardKind.closed => strings.noClosedTitle,
    };
    final body = switch (kind) {
      DeadlineBoardKind.inProgress => strings.noInProgressBody,
      DeadlineBoardKind.closed => strings.noClosedBody,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              kind == DeadlineBoardKind.inProgress
                  ? Icons.hourglass_top
                  : Icons.event_busy,
              size: 44,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              body,
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
  const _ErrorState({required this.error, required this.strings});

  final Object error;
  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(strings.loadError(error), textAlign: TextAlign.center),
      ),
    );
  }
}

enum _DeadlineAction { edit, delete }
