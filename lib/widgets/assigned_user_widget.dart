import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stutask/models/user.dart';

class AssignedUserWidget extends StatelessWidget {
  final UserModel assignedUser;
  final String taskId;
  final Function(String, int) onSubmitReview;

  const AssignedUserWidget({
    super.key,
    required this.assignedUser,
    required this.taskId,
    required this.onSubmitReview,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    int rating = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Przypisano do: ${assignedUser.firstName} ${assignedUser.lastName}',
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showReviewDialog(
            context,
            reviewController,
            rating,
            onSubmitReview,
          ),
          child: const Text('Wystaw opinię i zakończ zadanie'),
        ),
      ],
    );
  }

  void _showReviewDialog(
    BuildContext context,
    TextEditingController reviewController,
    int initialRating,
    Function(String, int) onSubmitReview,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int rating = initialRating;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Wystaw opinię'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ocena (od 1 do 5)'),
                  DropdownButton<int>(
                    value: rating,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          rating = value;
                        });
                      }
                    },
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Opinia',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final review = reviewController.text;
                    if (review.isNotEmpty) {
                      onSubmitReview(review, rating);
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        '/home',
                        arguments: {'user': User, 'accountType': "Pracodawca"},
                      );
                    }
                  },
                  child: const Text('Zatwierdź'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
