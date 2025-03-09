import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stutask/bloc/user_service.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  AdminReviewsScreenState createState() => AdminReviewsScreenState();
}

class AdminReviewsScreenState extends State<AdminReviewsScreen> {
  Future<List<Map<String, dynamic>>>? _reviews;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() {
    final userService = Provider.of<UserService>(context, listen: false);
    setState(() {
      _reviews = userService.fetchReviews();
    });
  }

  Future<void> _deleteReview(String userId, String reviewId) async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.deleteReview(userId, reviewId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opinia została usunięta.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchReviews(); // Odświeżanie listy po usunięciu opinii
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd podczas usuwania opinii: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opinie w aplikacji'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak opinii do wyświetlenia.'));
          }

          final reviews = snapshot.data!;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(review['review'] ?? 'Brak tytułu'),
                  subtitle: Text(review['taskId'] ?? 'Brak treści'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ocena: ${review['rating'] ?? 'Brak'}'),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteReview(review['userId'], review['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
