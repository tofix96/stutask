class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String accountType;
  final String bio;
  final String age;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.accountType,
    required this.bio,
    required this.age,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      firstName: data['Imię'] ?? '',
      lastName: data['Nazwisko'] ?? '',
      accountType: data['Typ_konta'] ?? '',
      bio: data['Bio'] ?? '',
      age: data['Wiek'] ?? '',
    );
  }
}
