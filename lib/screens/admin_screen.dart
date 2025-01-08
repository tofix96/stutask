import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/admin_review_screen.dart';
import 'package:stutask/widgets/task_list_view.dart';
import 'package:stutask/screens/auth/login_screen.dart';
import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  final User user;

  const AdminPage({super.key, required this.user});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int selectedIndex = 0;

  List<Widget> _widgetOptions(User user) => <Widget>[
        TaskListView(user: user),
        AdminReviewsScreen(),
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
      body: _widgetOptions(widget.user)[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Zadania',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Moje zadania',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 153, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}
