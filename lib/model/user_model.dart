class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final int? age;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.age,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'image_url': imageUrl,
      };

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      age: json['age'] as int?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
