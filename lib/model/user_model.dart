class UserModel {
  final String username;
  final String email;
  final String? uid;
  final Map<String, String> source;
  final String? profilePictureUrl;

  UserModel({
    required this.username,
    required this.email,
    required this.uid,
    required this.profilePictureUrl,
    Map<String, String>? source,
  }) : source =
           source ??
           {
             'email': 'not connected',
             'bank': 'not connected',
             'sms': 'not connected',
             'osr': 'not connected',
           };

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'source': source,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      uid: json['uid'],
      profilePictureUrl: json['profilePictureUrl'],
      source: Map<String, String>.from(
        json['source'] ??
            {
              'email': 'not connected',
              'bank': 'not connected',
              'sms': 'not connected',
              'osr': 'not connected',
            },
      ),
    );
  }
}
