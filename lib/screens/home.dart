// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/screens/login_screen.dart';
import 'package:stutask/screens/create_task_screen.dart'; // Import ekranu tworzenia zadania
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutask/screens/seetings_screen.dart';
import 'package:stutask/bloc/screen_controller.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final bool showEmployerTasks;

  const HomePage(
      {required this.user, this.showEmployerTasks = false, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ScreenController _screenController = ScreenController();

  static List<Widget> _widgetOptions(User user, bool showEmployerTasks) =>
      <Widget>[
        TaskListView(user: user, showEmployerTasks: showEmployerTasks),
        CreateTaskScreen(),
        TaskListView(user: user, showEmployerTasks: true),
        SettingsScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Przejdź do `HomePage` z filtrowaniem `false`, gdy wybrano zakładkę z listą zadań
    if (index == 0) {
      _screenController.navigateToHome(context, widget.user,
          showEmployerTasks: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stutask'),
        backgroundColor: Color.fromRGBO(239, 120, 16, 0.968),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Provider.of<custom_auth.AuthProvider>(context, listen: false)
                  .setToken(null);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: widget.user != null
          ? _widgetOptions(widget.user!, widget.showEmployerTasks)
              .elementAt(_selectedIndex)
          : const Center(child: Text('Nie znaleziono danych użytkownika.')),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista Zadań',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Dodaj Zadanie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Moje zadania',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 153, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget do wyświetlania listy z zadaniami
class TaskListView extends StatelessWidget {
  final User user;
  final bool showEmployerTasks;

  const TaskListView(
      {required this.user, this.showEmployerTasks = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dodaj filtr dla zadań, aby wyświetlić tylko zadania utworzone przez pracodawcę
    final taskStream = showEmployerTasks
        ? FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .snapshots()
        : FirebaseFirestore.instance.collection('tasks').snapshots();

    return StreamBuilder(
      stream: taskStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Brak zadań do wyświetlenia.'));
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return TaskTile(
              taskId: task.id,
              taskTitle: task['Nazwa'],
              taskDescription: task['Opis'],
              price: task['Cena'].toString(),
              imageUrl: task['zdjecie'],
            );
          },
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  final String taskId; // Dodanie taskId
  final String taskTitle;
  final String taskDescription;
  final String price;
  final String? imageUrl;

  const TaskTile({
    required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    required this.price,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _screenController = ScreenController();

    return InkWell(
      onTap: () {
        _screenController.navigateToTaskDetail(context, taskId);
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      taskDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Cena: $price PLN',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
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
}
