class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.emergencyContact = '',
    this.avatarBase64,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final String emergencyContact;
  final String? avatarBase64;

  factory UserProfile.fromFirestore(
    String uid,
    Map<String, dynamic>? data, {
    required String fallbackEmail,
    required String fallbackName,
  }) {
    final source = data ?? const <String, dynamic>{};
    return UserProfile(
      uid: uid,
      email: source['email'] as String? ?? fallbackEmail,
      name: source['name'] as String? ?? fallbackName,
      phone: source['phone'] as String? ?? '',
      emergencyContact: source['emergencyContact'] as String? ?? '',
      avatarBase64: source['avatarBase64'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'avatarBase64': avatarBase64,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? emergencyContact,
    String? avatarBase64,
    bool clearAvatar = false,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
    );
  }
}
