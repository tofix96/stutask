class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String age;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      firstName: data['Imię'] ?? 'Brak imienia',
      lastName: data['Nazwisko'] ?? 'Brak nazwiska',
      age: data['Wiek'] ?? 'Nieznany wiek',
    );
  }
}
