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

  const HomePage({required this.user, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Przechowywanie indeksu aktualnie wybranego ekranu

  // Lista widgetów (ekranów), które będą wyświetlane w zależności od wybranego indeksu
  static List<Widget> _widgetOptions(User user) => <Widget>[
        TaskListView(user: user), // Wyświetlanie listy zadań
        CreateTaskScreen(), // Ekran tworzenia nowego zadania
        SettingsScreen(), // Ekran ustawień zamiast placeholder // Możesz dodać więcej ekranów
      ];

  // Funkcja zmieniająca indeks wybranego ekranu
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final token = Provider.of<custom_auth.AuthProvider>(context).token;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stutask'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Provider.of<custom_auth.AuthProvider>(context, listen: false)
                  .setToken(null);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
      body: widget.user != null
          ? _widgetOptions(widget.user!)
              .elementAt(_selectedIndex) // Dynamiczna zmiana zawartości ekranu
          : const Center(child: Text('Nie znaleziono danych użytkownika.')),

      // Dolna nawigacja (BottomNavigationBar) do zmiany ekranów
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.settings),
            label: 'Ustawienia',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat_sharp),
          //   label: 'Chat',
          // ),
        ],
        currentIndex: _selectedIndex, // Aktualnie wybrany indeks
        selectedItemColor: Colors.blue, // Kolor zaznaczonego elementu
        onTap: _onItemTapped, // Wywołanie funkcji po kliknięciu na element
      ),
    );
  }
}

// Widget do wyświetlania listy z zadaniami
class TaskListView extends StatelessWidget {
  final User user;

  const TaskListView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
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
              taskTitle: task['Nazwa'],
              taskDescription: task['Opis'],
              price: task['Cena'].toString(), // Dodanie ceny
              imageUrl: task['zdjecie'], // Dodanie obsługi obrazów
            );
          },
        );
      },
    );
  }
}

// Widget kafelka zadania (zmieniony na listę)
class TaskTile extends StatelessWidget {
  final String taskTitle;
  final String taskDescription;
  final String price;
  final String? imageUrl;
  final ScreenController _screenController = ScreenController();

  TaskTile({
    required this.taskTitle,
    required this.taskDescription,
    required this.price, // Cena zadania
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _screenController.navigateToTaskDetail(
          context,
          taskTitle,
          taskDescription,
          price,
          imageUrl,
        );
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
