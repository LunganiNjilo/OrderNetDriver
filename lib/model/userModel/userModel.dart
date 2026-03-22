class userModel {
  String? name;
  String? userProfilePicUrl;
  String? userId;
  String? cloudMessageingToken;

  userModel({
    this.name,
    this.userProfilePicUrl,
    this.userId,
    this.cloudMessageingToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userProfilePicUrl': userProfilePicUrl,
      'userId': userId,
      'cloudMessageingToken': cloudMessageingToken,
    };
  }

  static userModel fromMap(Map<String, dynamic> map) {
    return userModel(
      name: map['name'] != null ? map['name'] as String : '',
      userProfilePicUrl: map['userProfilePicUrl'] ?? '',
      userId: map['userId'] ?? '',
      cloudMessageingToken: map['cloudMessageingToken'] ?? '',
    );
  }
}
