// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:stutask/bloc/screen_controller.dart';
import 'package:stutask/screens/chat/chats_overview_screen.dart';
import 'package:stutask/screens/auth/login_screen.dart';
import 'package:stutask/screens/tasks/create_task_screen.dart'; // Import ekranu tworzenia zadania
import 'package:stutask/screens/profile/seetings_screen.dart';

int selectedIndex = 0;

class HomePage extends StatefulWidget {
  final User? user;
  final bool showEmployerTasks;

  const HomePage(
      {required this.user, this.showEmployerTasks = false, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScreenController _screenController = ScreenController();
  String? accountType;
  @override
  void initState() {
    super.initState();
    _getAccountType(); // Pobierz typ konta przy inicjalizacji
  }

  Future<void> _getAccountType() async {
    final userId = widget.user?.uid;
    if (userId != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('D_Users')
          .doc(userId)
          .get();
      setState(() {
        accountType = userSnapshot.data()?['Typ_konta'];
      });
    }
  }

  static List<Widget> _widgetOptions(
    User user,
    bool showEmployerTasks,
  ) =>
      <Widget>[
        TaskListView(user: user, showEmployerTasks: showEmployerTasks),
        TaskListView(user: user, showEmployerTasks: true),
        SettingsScreen(),
        CreateTaskScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    // Przejdź do `HomePage` z filtrowaniem `false`, gdy wybrano zakładkę z listą zadań
    if (index == 0) {
      _screenController.navigateToHome(context, widget.user,
          showEmployerTasks: false);
    }
    if (index == 1) {
      _screenController.navigateToHome(context, widget.user,
          showEmployerTasks: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stutask'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black45,
              offset: Offset(2, 2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF6C00), Color(0xFFFFC107)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatOverviewScreen()),
              );
            },
          ),
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(137, 37, 37, 37),
                    blurRadius: 7,
                    offset: Offset(0.5, 1),
                    spreadRadius: 0.001,
                  ),
                ],
              ),
              child: const Icon(Icons.logout, color: Colors.white),
            ),
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
              .elementAt(selectedIndex)
          : const Center(child: Text('Nie znaleziono danych użytkownika.')),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Zadania',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Moje zadania',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profil',
          ),
          if (accountType ==
              'Pracodawca') // Wyświetl "Dodaj zadanie" tylko dla pracodawców
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Dodaj Zadanie',
            ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 153, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}

class TaskListView extends StatefulWidget {
  final User user;
  final bool showEmployerTasks;

  const TaskListView(
      {required this.user, this.showEmployerTasks = false, super.key});

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  String _sortField = 'Nazwa'; // Domyślne pole sortowania
  bool _isAscending = true; // Domyślne sortowanie rosnące
  String _category = 'Wszystkie'; // Domyślna kategoria
  List<Map<String, dynamic>> localData = []; // Dane lokalne

  @override
  void initState() {
    super.initState();
    _fetchData(); // Pobranie danych
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot;

      if (widget.showEmployerTasks) {
        // Jeśli wybrano "Moje zadania", filtruj tylko zadania użytkownika
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: widget.user.uid)
            .where('completed', isEqualTo: false) // Filtruj po użytkowniku
            .get();
      } else {
        // Jeśli wybrano wszystkie zadania, filtruj tylko po "completed"
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('completed', isEqualTo: false) // Filtruj po "completed"
            .orderBy('createdAt')
            .get();
      }

      // Przetwarzanie wyników
      setState(() {
        localData = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Dodanie identyfikatora dokumentu
          return data;
        }).toList();
      });
    } catch (e) {
      print('Błąd podczas pobierania danych: $e');
    }
  }

  List<Map<String, dynamic>> _applyFiltersAndSorting() {
    List<Map<String, dynamic>> filteredData = localData.where((task) {
      if (_category == 'Wszystkie') {
        return true;
      }
      return task['Kategoria'] == _category;
    }).toList();

    // Sortuj dane lokalnie
    filteredData.sort((a, b) {
      int comparison = 0;
      if (_sortField == 'Nazwa') {
        comparison = a['Nazwa'].compareTo(b['Nazwa']);
      } else if (_sortField == 'Cena') {
        comparison = (a['Cena'] as num).compareTo(b['Cena'] as num);
      } else if (_sortField == 'Czas') {
        comparison = a['Czas'].compareTo(b['Czas']);
      }

      return _isAscending ? comparison : -comparison;
    });

    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedIndex == 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _sortField,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortField = value;
                    });
                  }
                },
                items: <String>['Nazwa', 'Cena', 'Czas']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Sortuj wg $value'),
                  );
                }).toList(),
              ),
              IconButton(
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                onPressed: () {
                  setState(() {
                    _isAscending = !_isAscending;
                  });
                },
              ),
              DropdownButton<String>(
                value: _category,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
                items: <String>[
                  'Wszystkie',
                  'korepetycje',
                  'remont',
                  'prace przydomowe'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Kat: $value'),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
        Expanded(
            child: localData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _applyFiltersAndSorting().length,
                    itemBuilder: (context, index) {
                      final task = _applyFiltersAndSorting()[index];
                      print(task['Nazwa']);

                      return TaskTile(
                        taskId: task['id'] ?? '', // Zabezpieczenie przed `null`
                        taskTitle: task['Nazwa'] ??
                            'Brak nazwy', // Domyślna wartość, jeśli `null`
                        taskDescription: task['Opis'] ?? 'Brak opisu',
                        price: (task['Cena'] ?? 0)
                            .toString(), // Domyślna wartość dla liczby
                        imageUrl: task['zdjecie'] ??
                            '', // Domyślna wartość dla obrazu
                      );
                    },
                  )),
      ],
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
    final screenController = ScreenController();

    return InkWell(
      onTap: () {
        screenController.navigateToTaskDetail(context, taskId);
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
