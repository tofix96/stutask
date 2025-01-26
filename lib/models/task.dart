class Task {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String time;
  final String? imageUrl;
  final String creatorId;
  final bool completed;
  final String? assignedUserId;
  final String city;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.time,
    this.imageUrl,
    required this.creatorId,
    required this.completed,
    this.assignedUserId,
    required this.city,
  });

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['Nazwa'] ?? 'Brak nazwy',
      description: data['Opis'] ?? 'Brak opisu',
      price: (data['Cena'] ?? 0).toDouble(),
      category: data['Kategoria'] ?? 'Brak kategorii',
      time: data['Czas'] ?? 'Brak czasu',
      imageUrl: data['zdjecie'],
      creatorId: data['userId'] ?? '',
      completed: data['completed'] ?? false,
      assignedUserId: data['assignedUserId'],
      city: data['Miasto'] ?? 'Nieznane miasto', // Obsługa nowego pola
    );
  }
}
