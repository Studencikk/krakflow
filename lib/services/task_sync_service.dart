import 'task_api_service.dart';
import 'task_local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (TaskLocalDatabase.isEmpty()) {
      try {
        final tasks = await TaskApiService.fetchTasks();
        await TaskLocalDatabase.saveTasks(tasks);
      } catch (e) {
        print("Błąd pobierania danych z API: $e");
      }
    }
  }
}