class UserModel {
  final String username;
  final String email;
  final String? uid;
  final Map<String, String> source;

  UserModel({
    required this.username,
    required this.email,
    required this.uid,
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
    return {'username': username, 'email': email, 'uid': uid, 'source': source};
  }

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      uid: json['uid'],

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
