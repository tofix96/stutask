// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/screens/chats_overview_screen.dart';
import 'package:stutask/screens/login_screen.dart';
import 'package:stutask/screens/create_task_screen.dart'; // Import ekranu tworzenia zadania
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stutask/screens/seetings_screen.dart';
import 'package:stutask/bloc/screen_controller.dart';

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
        backgroundColor: const Color.fromRGBO(239, 120, 16, 0.968),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat), // Ikona czatu
            onPressed: () {
              // Akcja po kliknięciu ikony czatu
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        ChatOverviewScreen()), // Przejście do ekranu czatu
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout), // Ikona wylogowania
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
      // Pobranie danych z Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('completed', isEqualTo: false)
          .get();

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
    // Filtruj dane według kategorii
    List<Map<String, dynamic>> filteredData = localData.where((task) {
      if (_category == 'Wszystkie') {
        return true;
      }
      return task['Kategoria'] == _category;
    }).toList();

    // Sortuj dane
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
