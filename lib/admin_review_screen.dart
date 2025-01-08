import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({Key? key}) : super(key: key);

  @override
  _AdminReviewsScreenState createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  Future<List<Map<String, dynamic>>>? _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = _fetchReviews();
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    try {
      final userSnapshots =
          await FirebaseFirestore.instance.collection('D_Users').get();
      final reviews = <Map<String, dynamic>>[];

      for (var userDoc in userSnapshots.docs) {
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('D_Users')
            .doc(userDoc.id)
            .collection('reviews')
            .get();

        for (var reviewDoc in reviewsSnapshot.docs) {
          reviews.add(
              {'id': reviewDoc.id, 'userId': userDoc.id, ...reviewDoc.data()});
        }
      }

      return reviews;
    } catch (e) {
      throw Exception('Błąd podczas pobierania opinii: $e');
    }
  }

  Future<void> _deleteReview(String userId, String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('D_Users')
          .doc(userId)
          .collection('reviews')
          .doc(reviewId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opinia została usunięta.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _reviews = _fetchReviews();
      });
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
