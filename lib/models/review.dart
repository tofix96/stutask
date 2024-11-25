class Review {
  final double rating;

  Review({
    required this.rating,
  });

  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      rating: (data['rating'] as num).toDouble(),
    );
  }
}
