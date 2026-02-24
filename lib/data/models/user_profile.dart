import 'character.dart';

/// A user profile. Each profile has independent progression, schedule, and
/// workout history stored under its own namespaced SharedPreferences keys.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    this.characterType = CharacterType.male,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final CharacterType characterType;

  UserProfile copyWith({String? name, CharacterType? characterType}) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        characterType: characterType ?? this.characterType,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'characterType': characterType.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        characterType: CharacterType.fromKey(
          (json['characterType'] as String?) ?? 'male',
        ),
      );
}
