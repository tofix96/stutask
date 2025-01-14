import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stutask/bloc/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  CreateTaskScreenState createState() => CreateTaskScreenState();
}

class CreateTaskScreenState extends State<CreateTaskScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa zadania',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź nazwę zadania';
                    }
                    if (value.length > 50) {
                      return 'Nazwa zadania nie może przekraczać 50 znaków';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  maxLength: 300,
                  controller: _descriptionController,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                    counterText: '', // Opcjonalnie ukrycie licznika znaków
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź nazwę zadania';
                    }
                    if (value.length > 300) {
                      return 'Opis zadania nie może przekraczać 300 znaków';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  maxLength: 5,
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Cena (PLN)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź cenę';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Cena musi być dodatnią liczbą';
                    }
                    if (price > 99999) {
                      return 'Cena nie może przekraczać 99999 PLN';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Czas wykonania',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        _timeController.text =
                            '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}';
                      });
                    }
                  },
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

  Future<void> _loadUserName() async {
    _creatorName = await _taskService.getUserName();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedImage = await _taskService.pickImage();

    if (pickedImage != null) {
      final fileSize = await pickedImage.length();
      const maxSizeInBytes = 2 * 1024 * 1024;

      if (fileSize > maxSizeInBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Rozmiar zdjęcia nie może przekraczać 2 MB')),
        );
        return;
      }

      setState(() {
        _imageFile = pickedImage;
      });
    }
  }
}
