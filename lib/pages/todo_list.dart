// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:local_app_database/models/task.dart';
import 'package:local_app_database/services/database_services.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _task;
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff151c64),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size.width,
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To-Do List  📝',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff151c64),
                      ),
                    ),

                    // Text Field to add a new task
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _taskController,
                              onChanged: (value) {
                                setState(() {
                                  _task = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(right: 0, left: 14),
                                hintText: "Add your task",
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              // Add logic to handle task addition
                              if (_task == null || _task!.isEmpty) return;
                              _databaseServices.addTask(_task!);
                              setState(() {
                                _task = null;
                                _taskController.clear();
                              });
                            },
                            color: const Color(0xffff5845),
                            minWidth: 110, // Width of the button
                            height: size.height *
                                0.055, // Matches height with the TextField
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text("ADD"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // To-Do List
                    SizedBox(
                      width: size.width,
                      height: size.height * 0.76,
                      child: _tasksList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseServices.getTasks(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching tasks'));
        }

        // No data state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks available'));
        }

        // Data available state
        final tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            Task task = tasks[index];
            return ListTile(
              onLongPress: () {
                // Handle long press if needed
              },
              title: Row(
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: task.status == 1,
                      onChanged: (value) {
                        _databaseServices.updateTaskStatus(
                            task.id, value == true ? 1 : 0);
                        setState(() {});
                      },
                      shape: const CircleBorder(),
                      side: const BorderSide(color: Colors.grey, width: 1),
                      activeColor: const Color(0xffff5845),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between checkbox and text
                  Expanded(
                      child: Text(task
                          .content)), // Wrap text in Expanded for proper sizing
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        _updateContent(task); // Call update content function
                      },
                      icon: const Icon(Icons.mode_edit_outlined),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle delete logic
                        _databaseServices.deleteTask(task.id);
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateContent(Task task) {
    // Create a TextEditingController to hold the updated content
    TextEditingController _controller =
        TextEditingController(text: task.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Task'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter new task content',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Validate and update the task content
                if (_controller.text.isNotEmpty) {
                  _databaseServices.updateTaskContent(
                      task.id, _controller.text);
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {}); // Update the UI
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
