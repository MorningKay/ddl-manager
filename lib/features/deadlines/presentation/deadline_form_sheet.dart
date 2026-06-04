import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/deadline_providers.dart';
import '../domain/deadline.dart';
import 'deadline_formatters.dart';

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _isEditing ? 'Edit deadline' : 'Add deadline',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Text('Due time', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(formatDueAt(_dueAt).split(' ').first),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(formatDueAt(_dueAt).split(' ').last),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Priority', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<DeadlinePriority>(
                  segments: DeadlinePriority.values
                      .map(
                        (priority) => ButtonSegment(
                          value: priority,
                          label: Text(priority.label),
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
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save'),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _dueAt = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draft = DeadlineDraft(
      title: _titleController.text,
      dueAt: _dueAt,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save deadline: $error')),
        );
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
