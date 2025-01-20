import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/task_tile.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/bloc/task_service.dart';

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
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();

  String _sortField = 'Nazwa';
  bool _isAscending = true;
  String _category = 'Wszystkie';
  String _searchQuery = '';
  List<Map<String, dynamic>> localData = [];
  bool isLoading = true;
  String? accountType = 'NULL';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchAccountType();
    _fetchData();
  }

  Future<void> _fetchAccountType() async {
    final userId = widget.user.uid;
    final type = await _userService.getAccountType(userId);
    setState(() {
      accountType = type ?? 'Nieznany';
    });
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    try {
      final data = await _taskService.fetchTasks(
        accountType: accountType!,
        userId: widget.user.uid,
        filterByAssignedTasks: widget.filterByAssignedTasks,
        filterByCreatedTasks: widget.filterByCreatedTasks,
      );

      setState(() {
        localData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania zadań: $e')),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zadanie zostało usunięte.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania zadania: $e')),
      );
    }
  }

  Future<void> updateAdminAccept(String taskId) async {
    try {
      await _taskService.updateTask(taskId, {'admin_accept': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadanie zostało zaakceptowane.')),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas aktualizacji zadania: $e')),
      );
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
        // Pole wyszukiwania
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
        // Sortowanie i wybór kategorii
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sortowanie
              Row(
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
                ],
              ),
              // Wybór kategorii
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
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : localData.isEmpty
                  ? const Center(child: Text('Brak zadań do wyświetlenia.'))
                  : ListView.builder(
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
                          isAdminAccepted:
                              task['admin_accept'] as bool? ?? false,
                          onDelete: () => _deleteTask(task['id']),
                          onAdminAccept: () => updateAdminAccept(task['id']),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
