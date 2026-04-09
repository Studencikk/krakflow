import 'main.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Projekt Mario", deadline: "jutro", done: true, priority: "wysoki"),
    Task(title: "Ćwiczenia z plastyki", deadline: "dzisiaj", done: false, priority: "średni"),
    Task(title: "Przeczytać książkę", deadline: "w tym tygodniu", done: false, priority: "niski"),
    Task(title: "Skok na bungee", deadline: "w przyszłym tygodniu", done: true, priority: "wysoki"),
  ];
}