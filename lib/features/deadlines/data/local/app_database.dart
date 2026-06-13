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
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('QuickTagRow')
class QuickTagEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [DeadlineEntries, QuickTagEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.alterTable(TableMigration(deadlineEntries));
        } else if (from < 3) {
          await migrator.addColumn(deadlineEntries, deadlineEntries.tags);
        }
        if (from < 4) {
          await migrator.createTable(quickTagEntries);
        }
      },
    );
  }
}
