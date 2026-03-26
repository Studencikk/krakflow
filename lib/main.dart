import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = [
      Task(title: "Projekt Mario", deadline: "jutro", done: true, priority: "wysoki"),
      Task(title: "Ćwiczenia z plastyki", deadline: "dzisiaj", done: false, priority: "średni"),
      Task(title: "Przeczytać książkę", deadline: "w tym tygodniu", done: false, priority: "niski"),
      Task(title: "Skok na bungee", deadline: "w przyszłym tygodniu", done: true, priority: "wysoki"),
    ];

    return MaterialApp(
      title: "Flutter Demo",
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś ${tasks.length} zadania, wykonano: ${tasks.where((t) => t.done).length}"),
              SizedBox(height: 16),
              Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Task task = tasks[index];
                    return TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                      icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
