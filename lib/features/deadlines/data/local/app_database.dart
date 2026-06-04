import 'package:drift/drift.dart';

import '../../domain/deadline.dart';

part 'app_database.g.dart';

@DataClassName('DeadlineRow')
class DeadlineEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get dueAt => dateTime().nullable()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.alterTable(TableMigration(deadlineEntries));
        }
      },
    );
  }
}
