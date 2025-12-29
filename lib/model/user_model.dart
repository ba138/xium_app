class UserModel {
  final String username;
  final String email;
  final Map<String, String> source;

  UserModel({
    required this.username,
    required this.email,
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
    return {'username': username, 'email': email, 'source': source};
  }

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
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
