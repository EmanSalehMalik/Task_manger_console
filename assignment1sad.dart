import 'dart:io';
import 'dart:convert';

class Task {
  String title;
  String description;
  bool isCompleted = false;

  Task(this.title, this.description, this.isCompleted);

  Map<String, dynamic> getter() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

class TaskManager {
  List<Task> arr = [];

  void addTask(Task a) {
    arr.add(a);
  }

  void update(int i, Task a) {
    if (i >= 0 && i < arr.length) {
      arr[i] = a;
    } else {
      print('Invalid index');
    }
  }

  void delete(int i) {
    if (i >= 0 && i < arr.length) {
      arr.removeAt(i);
    } else {
      print('Invalid index');
    }
  }

  List<Task> getTasks() {
    return arr;
  }

  List<Task> completedTasks() {
    return arr.where((task) => task.isCompleted).toList();
  }

  List<Task> incompleteTasks() {
    return arr.where((task) => !task.isCompleted).toList();
  }

  void toggleStatusChange(int i) {
    if (i >= 0 && i < arr.length) {
      arr[i].isCompleted = !arr[i].isCompleted;
    } else {
      print('Invalid index');
    }
  }

  Future<void> saveTasks(String filePath) async {
    final file = File(filePath);
    final tasksJson = arr.map((task) => task.getter()).toList();
    await file.writeAsString(jsonEncode(tasksJson));
  }

  Future<void> loadTasks(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> tasksJson = jsonDecode(contents);
      arr =
          tasksJson
              .map(
                (json) => Task(
                  json['title'] as String,
                  json['description'] as String,
                  json['isCompleted'] as bool,
                ),
              )
              .toList();
    }
  }
}

void printMenu() {
  print('\n===== Task Manager =====');
  print('1. Add a new task');
  print('2. Update a task');
  print('3. Delete a task');
  print('4. List all tasks');
  print('5. List completed tasks');
  print('6. List incomplete tasks');
  print('7. Toggle task status');
  print('8. Exit');
  print('========================');
}

void main() async {
  final taskManager = TaskManager();
  final filePath = 'tasks.json';
  print("he;;p");
  // Load tasks from file
  try {
    await taskManager.loadTasks(filePath);
    print('Tasks loaded successfully!');
  } catch (e) {
    print('No existing tasks found or error loading tasks: $e');
  }

  while (true) {
    printMenu();
    stdout.write('Choose an option: ');
    String? input = stdin.readLineSync();
    print(input);
    var option = int.tryParse(input ?? '');

    if (option == null || option < 1 || option > 8) {
      print('Invalid option. Please enter a number between 1 and 8.');
      continue;
    }

    switch (option) {
      case 1:
        stdout.write('Enter task title: ');
        var title = stdin.readLineSync() ?? '';
        stdout.write('Enter task description: ');
        var description = stdin.readLineSync() ?? '';

        if (title.isNotEmpty && description.isNotEmpty) {
          taskManager.addTask(Task(title, description, false));
          print('Task added successfully!');
        } else {
          print('Invalid input. Title and description cannot be empty.');
        }
        break;
      case 2:
        if (taskManager.getTasks().isEmpty) {
          print('No tasks available to update.');
          break;
        }

        print('Current tasks:');
        for (int i = 0; i < taskManager.getTasks().length; i++) {
          var task = taskManager.getTasks()[i];
          print(
            '$i: ${task.title} - ${task.description} [${task.isCompleted ? "Completed" : "Incomplete"}]',
          );
        }

        stdout.write('Enter task index to update: ');
        var indexInput = stdin.readLineSync() ?? '';
        var index = int.tryParse(indexInput);

        if (index != null &&
            index >= 0 &&
            index < taskManager.getTasks().length) {
          var currentTask = taskManager.getTasks()[index];

          stdout.write('Enter new title (current: ${currentTask.title}): ');
          var title = stdin.readLineSync() ?? '';
          if (title.isEmpty) title = currentTask.title;

          stdout.write(
            'Enter new description (current: ${currentTask.description}): ',
          );
          var description = stdin.readLineSync() ?? '';
          if (description.isEmpty) description = currentTask.description;

          taskManager.update(
            index,
            Task(title, description, currentTask.isCompleted),
          );
          print('Task updated successfully!');
        } else {
          print('Invalid index');
        }
        break;
      case 3:
        if (taskManager.getTasks().isEmpty) {
          print('No tasks available to delete.');
          break;
        }

        print('Current tasks:');
        for (int i = 0; i < taskManager.getTasks().length; i++) {
          var task = taskManager.getTasks()[i];
          print(
            '$i: ${task.title} - ${task.description} [${task.isCompleted ? "Completed" : "Incomplete"}]',
          );
        }

        stdout.write('Enter task index to delete: ');
        var indexInput = stdin.readLineSync() ?? '';
        var index = int.tryParse(indexInput);

        if (index != null &&
            index >= 0 &&
            index < taskManager.getTasks().length) {
          taskManager.delete(index);
          print('Task deleted successfully!');
        } else {
          print('Invalid index');
        }
        break;
      case 4:
        if (taskManager.getTasks().isEmpty) {
          print('No tasks available.');
        } else {
          print('\n=== All Tasks ===');
          for (int i = 0; i < taskManager.getTasks().length; i++) {
            var task = taskManager.getTasks()[i];
            print(
              '$i: ${task.title} - ${task.description} [${task.isCompleted ? "Completed" : "Incomplete"}]',
            );
          }
        }
        break;
      case 5:
        var completedTasks = taskManager.completedTasks();
        if (completedTasks.isEmpty) {
          print('No completed tasks.');
        } else {
          print('\n=== Completed Tasks ===');
          for (int i = 0; i < completedTasks.length; i++) {
            var task = completedTasks[i];
            print('$i: ${task.title} - ${task.description}');
          }
        }
        break;
      case 6:
        var incompleteTasks = taskManager.incompleteTasks();
        if (incompleteTasks.isEmpty) {
          print('No incomplete tasks.');
        } else {
          print('\n=== Incomplete Tasks ===');
          for (int i = 0; i < incompleteTasks.length; i++) {
            var task = incompleteTasks[i];
            print('$i: ${task.title} - ${task.description}');
          }
        }
        break;
      case 7:
        if (taskManager.getTasks().isEmpty) {
          print('No tasks available to toggle status.');
          break;
        }

        print('Current tasks:');
        for (int i = 0; i < taskManager.getTasks().length; i++) {
          var task = taskManager.getTasks()[i];
          print(
            '$i: ${task.title} - ${task.description} [${task.isCompleted ? "Completed" : "Incomplete"}]',
          );
        }

        stdout.write('Enter task index to toggle status: ');
        var indexInput = stdin.readLineSync() ?? '';
        var index = int.tryParse(indexInput);

        if (index != null &&
            index >= 0 &&
            index < taskManager.getTasks().length) {
          taskManager.toggleStatusChange(index);
          var task = taskManager.getTasks()[index];
          print(
            'Task "${task.title}" is now ${task.isCompleted ? "completed" : "incomplete"}.',
          );
        } else {
          print('Invalid index');
        }
        break;
      case 8:
        try {
          await taskManager.saveTasks(filePath);
          print('Tasks saved successfully!');
        } catch (e) {
          print('Error saving tasks: $e');
        }
        print('Exiting Task Manager. Goodbye!');
        exit(0);
    }
  }
}
