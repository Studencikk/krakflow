import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'services/task_api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyFirstScreen(),
    );
  }
}

class MyFirstScreen extends StatefulWidget {
  const MyFirstScreen({super.key});

  @override
  State<MyFirstScreen> createState() => _MyFirstScreenState();
}

class _MyFirstScreenState extends State<MyFirstScreen> {
  String selectedFilter = "wszystkie";
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = TaskApiService.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Potwierdzenie"),
                    content: Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            TaskRepository.tasks.clear();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Usunięto wszystkie zadania")),
                          );
                        },
                        child: Text("Usuń"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final tasks = snapshot.data!;
          if (TaskRepository.tasks.isEmpty) {
            TaskRepository.tasks.addAll(tasks);
          }

          List<Task> filteredTasks;
          if (selectedFilter == "wykonane") {
            filteredTasks = TaskRepository.tasks.where((t) => t.done).toList();
          } else if (selectedFilter == "do zrobienia") {
            filteredTasks = TaskRepository.tasks.where((t) => !t.done).toList();
          } else {
            filteredTasks = List.from(TaskRepository.tasks);
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masz dziś ${TaskRepository.tasks.length} zadania, "
                      "wykonano: ${TaskRepository.tasks.where((t) => t.done).length}",
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _FilterButton(label: "Wszystkie",    isActive: selectedFilter == "wszystkie",    onPressed: () => setState(() => selectedFilter = "wszystkie")),
                    SizedBox(width: 4),
                    _FilterButton(label: "Do zrobienia", isActive: selectedFilter == "do zrobienia", onPressed: () => setState(() => selectedFilter = "do zrobienia")),
                    SizedBox(width: 4),
                    _FilterButton(label: "Wykonane",     isActive: selectedFilter == "wykonane",     onPressed: () => setState(() => selectedFilter = "wykonane")),
                  ],
                ),
                SizedBox(height: 8),
                Text("Dzisiejsze zadania", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      Task task = filteredTasks[index];
                      return Dismissible(
                        key: Key(task.title),
                        onDismissed: (direction) {
                          setState(() {
                            TaskRepository.tasks.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Zadanie ${task.title} zostało usunięte")),
                          );
                        },
                        child: TaskCard(
                          title: task.title,
                          subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                          done: task.done,
                          onTap: () async {
                            final Task? updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTaskScreen(task: task),
                              ),
                            );
                            if (updatedTask != null) {
                              setState(() {
                                final realIndex = TaskRepository.tasks.indexOf(task);
                                TaskRepository.tasks[realIndex] = updatedTask;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin (np. 2024-12-31)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final deadline = deadlineController.text;

                  final newTask = Task(
                    title: title,
                    deadline: deadline,
                    done: false,
                    priority: "niski",
                  );

                  Navigator.pop(context, newTask);
                },
                child: Text("Zapisz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  final TextEditingController titleController;
  final TextEditingController deadlineController;

  EditTaskScreen({super.key, required this.task}) :
        titleController = TextEditingController(text: task.title),
        deadlineController = TextEditingController(text: task.deadline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin (np. 2024-12-31)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updatedTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    done: task.done,
                    priority: task.priority,
                  );

                  Navigator.pop(context, updatedTask);
                },
                child: Text("Zapisz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),
      body: Center(
        child: Text("Lista zadań"),
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
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterButton({required this.label, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isActive ? color : Colors.transparent,
        foregroundColor: isActive ? Colors.white : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 2),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      child: Text(label),
    );
  }
}