import 'package:drift/drift.dart';

import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    as platform;

QueryExecutor openDatabaseConnection() {
  return platform.openDatabaseConnection();
}
