import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/task_list_view.dart';

class AssignedTasksScreen extends StatefulWidget {
  final User user;
  final String accountType;

  const AssignedTasksScreen({
    required this.user,
    required this.accountType,
    super.key,
  });

  @override
  AssignedTasksScreenState createState() => AssignedTasksScreenState();
}

class AssignedTasksScreenState extends State<AssignedTasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaskListView(
        user: widget.user,
        filterByAssignedTasks: widget.accountType == 'Pracownik',
        filterByCreatedTasks: widget.accountType == 'Pracodawca',
      ),
    );
  }
}
