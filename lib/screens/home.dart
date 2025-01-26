// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/task_list_view.dart';
import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:stutask/screens/chat/chats_overview_screen.dart';
import 'package:stutask/screens/auth/login_screen.dart';
import 'package:stutask/screens/tasks/create_task_screen.dart';
import 'package:stutask/screens/profile/seetings_screen.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/screens/tasks/assigned_tasks_screen.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final bool showEmployerTasks;

  const HomePage(
      {required this.user, this.showEmployerTasks = false, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  int selectedIndex = 0;
  String? accountType = 'Pracownik';
  @override
  void initState() {
    super.initState();
    _fetchAccountType();
  }

  Future<void> _fetchAccountType() async {
    final userId = widget.user?.uid;
    if (userId != null) {
      final type = await _userService.getAccountType(userId);
      setState(() {
        accountType = type ?? 'Nieznany';
      });
    } else {
      print('User ID jest null');
    }
  }

  List<Widget> _widgetOptions(
    User user,
    bool showEmployerTasks,
  ) =>
      <Widget>[
        TaskListView(user: user),
        AssignedTasksScreen(user: user, accountType: accountType ?? 'Nieznany'),
        SettingsScreen(),
        CreateTaskScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
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
              Provider.of<custom_auth.AuthProvider>(context, listen: false);
              // .setToken(null);
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
          if (accountType == 'Pracodawca')
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Dodaj Zadanie',
            ),
        ],
        currentIndex: (selectedIndex == 0 ||
                selectedIndex == 1 ||
                selectedIndex == 2 ||
                selectedIndex == 3)
            ? selectedIndex
            : 0,
        selectedItemColor: const Color.fromARGB(255, 255, 153, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}
