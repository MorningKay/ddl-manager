import 'package:drift/drift.dart';

import '../../domain/deadline.dart';

part 'app_database.g.dart';

@DataClassName('DeadlineRow')
class DeadlineEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get priority =>
      text().withDefault(Constant(DeadlinePriority.medium.name))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [DeadlineEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
