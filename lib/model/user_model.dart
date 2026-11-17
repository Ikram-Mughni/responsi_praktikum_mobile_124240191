// TODO (RESPONSI): Pastikan typeId unik jika membuat class model Hive yang baru (contoh: @HiveType(typeId: 0)).
class UserModel {
  // TODO (RESPONSI): Sesuaikan atribut user jika diperlukan (misal: username, password, email, token).
  final String username;
  final String password;

  UserModel({
    required this.username,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
