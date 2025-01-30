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
  String? _category;
  String _searchQuery = '';
  List<Map<String, dynamic>> localData = [];
  bool isLoading = true;
  String? accountType = 'NULL';
  String? _selectedCity;

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
      if (_category != null &&
          _category != 'Wszystkie' &&
          task['Kategoria'] != _category) {
        return false;
      }

      if (_selectedCity != null &&
          _selectedCity!.isNotEmpty &&
          task['Miasto'] != _selectedCity) {
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _selectedCity,
                hint: const Text('Miasto'),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                items: <String>[
                  'Warszawa',
                  'Kraków',
                  'Gdańsk',
                  'Wrocław',
                  'Poznań',
                  'Rzeszów',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: Icon(Icons.unfold_more),
                onSelected: (value) {
                  setState(() {
                    switch (value) {
                      case 'Nazwa A-Z':
                        _sortField = 'Nazwa';
                        _isAscending = true;
                        break;
                      case 'Nazwa Z-A':
                        _sortField = 'Nazwa';
                        _isAscending = false;
                        break;
                      case 'Najdroższe':
                        _sortField = 'Cena';
                        _isAscending = false;
                        break;
                      case 'Najtańsze':
                        _sortField = 'Cena';
                        _isAscending = true;
                        break;
                      case 'Najszybciej':
                        _sortField = 'Czas';
                        _isAscending = true;
                        break;
                      case 'Najpóźniej':
                        _sortField = 'Czas';
                        _isAscending = false;
                        break;
                    }
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Nazwa A-Z',
                    child: Text('Nazwa A-Z'),
                  ),
                  PopupMenuItem(
                    value: 'Nazwa Z-A',
                    child: Text('Nazwa Z-A'),
                  ),
                  PopupMenuItem(
                    value: 'Najdroższe',
                    child: Text('Najdroższe'),
                  ),
                  PopupMenuItem(
                    value: 'Najtańsze',
                    child: Text('Najtańsze'),
                  ),
                  PopupMenuItem(
                    value: 'Najszybciej',
                    child: Text('Najszybciej'),
                  ),
                  PopupMenuItem(
                    value: 'Najpóźniej',
                    child: Text('Najpóźniej'),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _category,
                hint: const Text('Kategorie'),
                onChanged: (value) {
                  setState(() {
                    _category = value ?? 'Wszystkie';
                  });
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
                              task['admin_accept'] as bool? ?? true,
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
