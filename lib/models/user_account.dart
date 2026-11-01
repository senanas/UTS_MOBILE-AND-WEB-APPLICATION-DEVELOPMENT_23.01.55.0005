/// Role pengguna aplikasi ChronoStore.
enum UserRole {
  admin,
  customer;

  String get label => this == UserRole.admin ? 'Admin' : 'Pelanggan';
}

/// Model akun pengguna.
class UserAccount {
  final String id;
  final String name;
  final String email;
  final String password; // mock — tidak di-hash di fase lokal
  final UserRole role;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
    );
  }
}
