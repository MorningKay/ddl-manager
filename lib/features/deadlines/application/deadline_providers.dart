import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_deadline_repository.dart';
import '../data/in_memory_deadline_repository.dart';
import '../data/local/app_database.dart';
import '../data/local/database_connection.dart';
import '../domain/deadline.dart';
import '../domain/deadline_repository.dart';

final deadlineRepositoryProvider = Provider<DeadlineRepository>((ref) {
  final repository = kIsWeb
      ? InMemoryDeadlineRepository()
      : DriftDeadlineRepository(AppDatabase(openDatabaseConnection()));

  ref.onDispose(() {
    repository.close();
  });
  return repository;
});

final deadlinesProvider = StreamProvider<List<Deadline>>((ref) {
  return ref.watch(deadlineRepositoryProvider).watchDeadlines();
});
