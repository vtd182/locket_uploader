class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String idToken;
  final String profilePicture;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.idToken,
    required this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['localId'],
      email: json['email'],
      displayName: json['displayName'],
      idToken: json['idToken'],
      profilePicture: json['profilePicture'],
    );
  }
}
