class UserModel {
  final String name;
  final String email;
  final String type;
  final String id;

  UserModel({
    required this.name,
    required this.email,
    this.type = 'doctor',
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'type': type,
      'id': id,
    };
  }
}