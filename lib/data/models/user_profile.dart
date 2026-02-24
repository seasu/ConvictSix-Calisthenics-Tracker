/// A user profile. Each profile has independent progression, schedule, and
/// workout history stored under its own namespaced SharedPreferences keys.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  UserProfile copyWith({String? name}) => UserProfile(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
