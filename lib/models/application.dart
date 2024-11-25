class Application {
  final String userId;

  Application({
    required this.userId,
  });

  factory Application.fromFirestore(Map<String, dynamic> data) {
    return Application(
      userId: data['userId'],
    );
  }
}
