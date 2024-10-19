// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:local_app_database/models/task.dart';
import 'package:local_app_database/services/database_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _task; // No need to initialize explicitly with null

  @override
  Widget build(BuildContext context) {
    // Corrected parameter type
    return Scaffold(
      floatingActionButton: _addTaskButton(),
      body: _taskList(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add Task"),
            content: SingleChildScrollView(
              // Ensure content doesn't overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _task = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter task...",
                    ),
                  ),
                  const SizedBox(height: 10), // Added spacing for better UI
                  MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (_task == null || _task!.isEmpty)
                        // ignore: curly_braces_in_flow_control_structures
                        return; // Simplified null/empty check
                      _databaseServices.addTask(_task!);

                      setState(() {
                        _task = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Done!",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _taskList() {
    return FutureBuilder(
        future: _databaseServices.getTasks(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                onLongPress: () {
                  _databaseServices.deleteTask(task.id);
                  setState(() {});
                },
                title: Text(task.content),
                trailing: Checkbox(
                  value: task.status == 1,
                  onChanged: (value) {
                    _databaseServices.updateTaskStatus(
                        task.id, value == true ? 1 : 0);
                    setState(() {});
                  },
                ),
              );
            },
          );
        });
  }
}
