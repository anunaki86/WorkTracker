class AppUser {
  final String email;
  final String password; // W prawdziwej aplikacji przechowuj hashed password
  final String? name;

  AppUser({
    required this.email, 
    required this.password, 
    this.name
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password, // W prawdziwej aplikacji użyj bezpiecznego hashowania
      'name': name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      password: json['password'],
      name: json['name'],
    );
  }
}