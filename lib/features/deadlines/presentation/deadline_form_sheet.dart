import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_language.dart';
import '../application/deadline_providers.dart';
import '../domain/deadline.dart';
import 'deadline_formatters.dart';
import 'deadline_strings.dart';
import 'deadline_style.dart';

class DeadlineFormSheet extends ConsumerStatefulWidget {
  const DeadlineFormSheet({super.key, this.deadline});

  final Deadline? deadline;

  @override
  ConsumerState<DeadlineFormSheet> createState() => _DeadlineFormSheetState();
}

class _DeadlineFormSheetState extends ConsumerState<DeadlineFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _dueAt;
  late DeadlinePriority _priority;
  late bool _isDateUnannounced;
  bool _isSaving = false;

  bool get _isEditing => widget.deadline != null;

  @override
  void initState() {
    super.initState();
    final deadline = widget.deadline;
    _titleController = TextEditingController(text: deadline?.title ?? '');
    _notesController = TextEditingController(text: deadline?.notes ?? '');
    _dueAt = deadline?.dueAt ?? _defaultDueAt();
    _priority = deadline?.priority ?? DeadlinePriority.medium;
    _isDateUnannounced = deadline != null && deadline.dueAt == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final strings = DeadlineStrings(language);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? strings.editDeadline : strings.addDeadline,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: strings.title,
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return strings.titleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: strings.notes,
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.dueTime,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.dateUnannounced),
                  value: _isDateUnannounced,
                  onChanged: (value) {
                    setState(() {
                      _isDateUnannounced = value;
                    });
                  },
                ),
                if (!_isDateUnannounced) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(formatDueDate(_dueAt, language)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HourField(
                          value: _dueAt.hour,
                          label: strings.hour,
                          onChanged: _setHour,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MinuteField(
                          value: _dueAt.minute,
                          label: strings.minute,
                          onChanged: _setMinute,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  strings.priority,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<DeadlinePriority>(
                  segments: DeadlinePriority.values
                      .map(
                        (priority) => ButtonSegment(
                          value: priority,
                          icon: Icon(
                            Icons.flag,
                            color: priorityColor(priority, colorScheme),
                          ),
                          label: Text(strings.priorityName(priority)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {_priority},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _priority = selected.single;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : () => _save(strings),
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(strings.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _dueAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dueAt.hour,
        _dueAt.minute,
      );
    });
  }

  void _setHour(int hour) {
    setState(() {
      _dueAt = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        hour,
        _dueAt.minute,
      );
    });
  }

  void _setMinute(int minute) {
    setState(() {
      _dueAt = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        _dueAt.hour,
        minute,
      );
    });
  }

  Future<void> _save(DeadlineStrings strings) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draft = DeadlineDraft(
      title: _titleController.text,
      dueAt: _isDateUnannounced ? null : _dueAt,
      notes: _notesController.text,
      priority: _priority,
    );

    try {
      final repository = ref.read(deadlineRepositoryProvider);
      final deadline = widget.deadline;
      if (deadline == null) {
        await repository.createDeadline(draft);
      } else {
        await repository.updateDeadline(deadline.id, draft);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.saveError(error))));
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  DateTime _defaultDueAt() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 17);
  }
}

class _HourField extends StatelessWidget {
  const _HourField({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: List.generate(24, (hour) {
        return DropdownMenuItem(value: hour, child: Text(_twoDigits(hour)));
      }),
      onChanged: (hour) {
        if (hour != null) {
          onChanged(hour);
        }
      },
    );
  }
}

class _MinuteField extends StatelessWidget {
  const _MinuteField({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: List.generate(60, (minute) {
        return DropdownMenuItem(value: minute, child: Text(_twoDigits(minute)));
      }),
      onChanged: (minute) {
        if (minute != null) {
          onChanged(minute);
        }
      },
    );
  }
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
