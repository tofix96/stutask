import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/task_tile.dart';
import 'package:stutask/bloc/user_service.dart';

class TaskListView extends StatefulWidget {
  final User user;
  final bool showEmployerTasks;
  final bool filterByAssignedTasks;
  final bool filterByCreatedTasks;

  const TaskListView({
    required this.user,
    this.showEmployerTasks = false,
    this.filterByAssignedTasks = false,
    this.filterByCreatedTasks = false,
    super.key,
  });

  @override
  TaskListViewState createState() => TaskListViewState();
}

class TaskListViewState extends State<TaskListView> {
  String _sortField = 'Nazwa';
  bool _isAscending = true;
  String _category = 'Wszystkie';
  String _searchQuery = '';
  List<Map<String, dynamic>> localData = [];
  bool isLoading = true;
  final UserService _userService = UserService();
  String? accountType = 'NULL';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchAccountType();
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zadanie zostało usunięte.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd podczas usuwania zadania: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchAccountType() async {
    final userId = widget.user.uid;
    final type = await _userService.getAccountType(userId);
    setState(() {
      accountType = type ?? 'Nieznany';
    });
    print(accountType);
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot;

      if (widget.filterByAssignedTasks) {
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedUserId', isEqualTo: widget.user.uid)
            .where('completed', isEqualTo: false)
            .get();
      } else if (widget.filterByCreatedTasks) {
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: widget.user.uid)
            .where('completed', isEqualTo: false)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('completed', isEqualTo: false)
            .orderBy('createdAt')
            .get();
      }

      setState(() {
        localData = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Błąd podczas pobierania danych: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _applyFiltersAndSorting() {
    List<Map<String, dynamic>> filteredData = localData.where((task) {
      if (_category != 'Wszystkie' && task['Kategoria'] != _category) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return (task['Nazwa'] ?? '').toLowerCase().contains(query) ||
            (task['Opis'] ?? '').toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Sortowanie danych
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Wyszukaj zadania',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),
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
                'prace przydomowe',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Kat: $value'),
                );
              }).toList(),
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : localData.isEmpty
                  ? const Center(child: Text('Brak zadań do wyświetlenia.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _applyFiltersAndSorting().length,
                      itemBuilder: (context, index) {
                        final task = _applyFiltersAndSorting()[index];
                        return TaskTile(
                          taskId: task['id'] ?? '',
                          taskTitle: task['Nazwa'] ?? 'Brak nazwy',
                          taskDescription: task['Opis'] ?? 'Brak opisu',
                          price: (task['Cena'] ?? 0).toString(),
                          imageUrl: task['zdjecie'] ?? '',
                          isAdmin: accountType == 'Administrator',
                          onDelete: () => _deleteTask(task['id']),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
