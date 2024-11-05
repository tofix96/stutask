import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stutask/bloc/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _timeController = TextEditingController();
  final TaskService _taskService = TaskService();
  File? _imageFile;
  String? _creatorName;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    _creatorName = await _taskService.getUserName();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedImage = await _taskService.pickImage();
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz nowe zadanie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nazwa zadania'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Wprowadź nazwę zadania'
                      : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Opis zadania'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Wprowadź opis zadania'
                      : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Cena (PLN)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null ||
                          value.isEmpty ||
                          double.tryParse(value) == null
                      ? 'Wprowadź poprawną cenę'
                      : null,
                ),
                TextFormField(
                  controller: _timeController,
                  decoration:
                      const InputDecoration(labelText: 'Czas wykonania'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Wprowadź czas wykonania zadania'
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Wybierz kategorię'),
                  items: [
                    'remont',
                    'prace przydomowe',
                    'pomoc sąsiedzka',
                    'korepetycje'
                  ]
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Wybierz kategorię' : null,
                ),
                const SizedBox(height: 10),
                _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : const Text('Brak zdjęcia'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Wybierz zdjęcie'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _taskService.createTaskWithValidation(
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    timeController: _timeController,
                    selectedCategory: _selectedCategory,
                    creatorName: _creatorName,
                    imageFile: _imageFile,
                    context: context,
                  ),
                  child: const Text('Utwórz zadanie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
