import 'dart:async';

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

final deadlineNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

class DeadlineListScreen extends ConsumerWidget {
  const DeadlineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final strings = DeadlineStrings(language);
    final nowFactory = ref.watch(deadlineNowProvider);
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
            nowFactory: nowFactory,
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

class _DeadlineTabs extends StatefulWidget {
  const _DeadlineTabs({
    required this.deadlines,
    required this.nowFactory,
    required this.language,
    required this.strings,
  });

  final List<Deadline> deadlines;
  final DateTime Function() nowFactory;
  final AppLanguage language;
  final DeadlineStrings strings;

  @override
  State<_DeadlineTabs> createState() => _DeadlineTabsState();
}

class _DeadlineTabsState extends State<_DeadlineTabs>
    with WidgetsBindingObserver {
  late DateTime _now;
  Timer? _clockTimer;
  final Set<String> _selectedTags = {};
  bool _tagsExpanded = false;

  @override
  void initState() {
    super.initState();
    _now = widget.nowFactory();
    WidgetsBinding.instance.addObserver(this);
    _scheduleClockTick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNow();
    }
  }

  @override
  void didUpdateWidget(covariant _DeadlineTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final availableTags = deadlineTagOptions(widget.deadlines).toSet();
    _selectedTags.removeWhere((tag) => !availableTags.contains(tag));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deadlines.isEmpty) {
      return _EmptyState(strings: widget.strings);
    }

    final board = buildDeadlineBoard(widget.deadlines, now: _now);
    final tagOptions = deadlineTagOptions(widget.deadlines);
    final selectedTags = Set<String>.unmodifiable(_selectedTags);

    return TabBarView(
      children: [
        _DeadlineBoardPage(
          column: filterDeadlineBoardColumnByTags(
            board.inProgress,
            selectedTags,
          ),
          hasActiveFilter: selectedTags.isNotEmpty,
          now: _now,
          language: widget.language,
          strings: widget.strings,
          tagOptions: tagOptions,
          selectedTags: selectedTags,
          tagsExpanded: _tagsExpanded,
          onAllTagsSelected: _clearTagFilter,
          onTagToggled: _toggleTagFilter,
          onTagsExpandedChanged: _setTagsExpanded,
        ),
        _DeadlineBoardPage(
          column: filterDeadlineBoardColumnByTags(board.closed, selectedTags),
          hasActiveFilter: selectedTags.isNotEmpty,
          now: _now,
          language: widget.language,
          strings: widget.strings,
          tagOptions: tagOptions,
          selectedTags: selectedTags,
          tagsExpanded: _tagsExpanded,
          onAllTagsSelected: _clearTagFilter,
          onTagToggled: _toggleTagFilter,
          onTagsExpandedChanged: _setTagsExpanded,
        ),
      ],
    );
  }

  void _refreshNow() {
    if (!mounted) {
      return;
    }

    setState(() {
      _now = widget.nowFactory();
    });
    _scheduleClockTick();
  }

  void _scheduleClockTick() {
    _clockTimer?.cancel();
    final now = widget.nowFactory();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    final delay = nextMinute.difference(now);
    _clockTimer = Timer(delay, _refreshNow);
  }

  void _clearTagFilter() {
    setState(() {
      _selectedTags.clear();
    });
  }

  void _toggleTagFilter(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _setTagsExpanded(bool isExpanded) {
    setState(() {
      _tagsExpanded = isExpanded;
    });
  }
}

class _DeadlineBoardPage extends StatelessWidget {
  const _DeadlineBoardPage({
    required this.column,
    required this.hasActiveFilter,
    required this.now,
    required this.language,
    required this.strings,
    required this.tagOptions,
    required this.selectedTags,
    required this.tagsExpanded,
    required this.onAllTagsSelected,
    required this.onTagToggled,
    required this.onTagsExpandedChanged,
  });

  final DeadlineBoardColumn column;
  final bool hasActiveFilter;
  final DateTime now;
  final AppLanguage language;
  final DeadlineStrings strings;
  final List<String> tagOptions;
  final Set<String> selectedTags;
  final bool tagsExpanded;
  final VoidCallback onAllTagsSelected;
  final ValueChanged<String> onTagToggled;
  final ValueChanged<bool> onTagsExpandedChanged;

  @override
  Widget build(BuildContext context) {
    if (column.isEmpty && !hasActiveFilter) {
      return _EmptyBoardState(kind: column.kind, strings: strings);
    }

    final progressWindow = deadlineProgressWindow([
      ...column.scheduled,
      ...column.completed,
    ], now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        if (tagOptions.isNotEmpty) ...[
          _TagFilterBar(
            tags: tagOptions,
            selectedTags: selectedTags,
            isExpanded: tagsExpanded,
            strings: strings,
            onAllSelected: onAllTagsSelected,
            onTagToggled: onTagToggled,
            onExpandedChanged: onTagsExpandedChanged,
          ),
          const SizedBox(height: 12),
        ],
        if (column.isEmpty) ...[_EmptyTagFilterState(strings: strings)],
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

class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({
    required this.tags,
    required this.selectedTags,
    required this.isExpanded,
    required this.strings,
    required this.onAllSelected,
    required this.onTagToggled,
    required this.onExpandedChanged,
  });

  final List<String> tags;
  final Set<String> selectedTags;
  final bool isExpanded;
  final DeadlineStrings strings;
  final VoidCallback onAllSelected;
  final ValueChanged<String> onTagToggled;
  final ValueChanged<bool> onExpandedChanged;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _TagFilterChip(
        label: strings.allTags,
        isSelected: selectedTags.isEmpty,
        onSelected: onAllSelected,
      ),
      for (final tag in tags)
        _TagFilterChip(
          label: tag,
          isSelected: selectedTags.contains(tag),
          onSelected: () => onTagToggled(tag),
        ),
    ];

    if (isExpanded) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...chips,
          IconButton.outlined(
            tooltip: strings.collapseTags,
            onPressed: () => onExpandedChanged(false),
            icon: const Icon(Icons.expand_less),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => chips[index],
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: chips.length,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: strings.expandTags,
          onPressed: () => onExpandedChanged(true),
          icon: const Icon(Icons.expand_more),
        ),
      ],
    );
  }
}

class _TagFilterChip extends StatelessWidget {
  const _TagFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 128),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      selected: isSelected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      avatar: Icon(isSelected ? Icons.check : Icons.sell, size: 16),
      onSelected: (_) => onSelected(),
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
                                      if (deadline.tags.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        _DeadlineTagWrap(tags: deadline.tags),
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

class _DeadlineTagWrap extends StatelessWidget {
  const _DeadlineTagWrap({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [for (final tag in tags) _DeadlineTagPill(label: tag)],
    );
  }
}

class _DeadlineTagPill extends StatelessWidget {
  const _DeadlineTagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
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
      ),
    );
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

class _EmptyTagFilterState extends StatelessWidget {
  const _EmptyTagFilterState({required this.strings});

  final DeadlineStrings strings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell_outlined, size: 42, color: colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            strings.noMatchingTagsTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            strings.noMatchingTagsBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
