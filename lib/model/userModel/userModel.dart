class userModel {
  String? displayName;
  String? userProfilePicUrl;
  String? userId;
  String? cloudMessagingToken;

  userModel({
    this.displayName,
    this.userProfilePicUrl,
    this.userId,
    this.cloudMessagingToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'userProfilePicUrl': userProfilePicUrl,
      'userId': userId,
      'cloudMessagingToken': cloudMessagingToken,
    };
  }

  static userModel fromMap(Map<String, dynamic> map) {
    return userModel(
      displayName: map['displayName'] != null
          ? map['displayName'] as String
          : '',
      userProfilePicUrl: map['userProfilePicUrl'] ?? '',
      userId: map['userId'] ?? '',
      cloudMessagingToken: map['cloudMessagingToken'] ?? '',
    );
  }
}
