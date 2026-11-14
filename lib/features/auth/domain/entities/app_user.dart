final class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? email;
  final String? name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            other.id == id &&
            other.email == email &&
            other.name == name &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, email, name, createdAt, updatedAt);
}
