import 'package:flutter/material.dart';
import 'package:stutask/bloc/screen_controller.dart';

class TaskTile extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  final String taskDescription;
  final String price;
  final String? imageUrl;
  final bool isAdmin;
  final bool isAdminAccepted;
  final VoidCallback onDelete;
  final VoidCallback? onAdminAccept;

  const TaskTile({
    required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    required this.price,
    this.imageUrl,
    required this.isAdmin,
    required this.isAdminAccepted,
    required this.onDelete,
    this.onAdminAccept,
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
              if (isAdmin)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                    if (!isAdminAccepted)
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.blue),
                        onPressed: onAdminAccept,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
