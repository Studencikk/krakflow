import '../main.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(id: 1, title: "Projekt Mario", deadline: "jutro", done: true, priority: "wysoki"),
    Task(id: 2, title: "Ćwiczenia z plastyki", deadline: "dzisiaj", done: false, priority: "średni"),
    Task(id: 3, title: "Przeczytać książkę", deadline: "w tym tygodniu", done: false, priority: "niski"),
    Task(id: 4, title: "Skok na bungee", deadline: "w przyszłym tygodniu", done: true, priority: "wysoki"),
  ];
}