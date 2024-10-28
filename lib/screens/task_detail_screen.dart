import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final taskTitle = arguments?['taskTitle'] ?? 'Brak tytułu';
    final taskDescription = arguments?['taskDescription'] ?? 'Brak opisu';
    final price = arguments?['price'] ?? 'Brak ceny';
    final imageUrl = arguments?['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(taskTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) Image.network(imageUrl),
            const SizedBox(height: 10),
            Text(
              taskDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Cena: $price PLN',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
