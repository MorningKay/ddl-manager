import 'deadline.dart';

abstract class DeadlineRepository {
  Stream<List<Deadline>> watchDeadlines();

  Future<List<Deadline>> listDeadlines();

  Future<int> createDeadline(DeadlineDraft draft);

  Future<void> updateDeadline(int id, DeadlineDraft draft);

  Future<void> deleteDeadline(int id);

  Future<void> toggleCompleted(int id, bool isCompleted);

  Future<void> close();
}
