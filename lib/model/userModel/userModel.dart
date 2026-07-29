class userModel {
  String? displayName;
  String? userProfilePicUrl;
  String? userId;
  String? cloudMessagingToken;
  String? phoneNumber;
  String? email;
  String? authProvider;
  bool? isPhoneVerified;
  DateTime? createdAt;
  DateTime? lastLoginAt;

  userModel({
    this.displayName,
    this.userProfilePicUrl,
    this.userId,
    this.cloudMessagingToken,
    this.phoneNumber,
    this.email,
    this.authProvider,
    this.isPhoneVerified = false,
    this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    if (displayName != null) {
      data['displayName'] = displayName;
    }

    if (userProfilePicUrl != null) {
      data['userProfilePicUrl'] = userProfilePicUrl;
    }

    if (userId != null) {
      data['userId'] = userId;
    }

    if (cloudMessagingToken != null) {
      data['cloudMessagingToken'] = cloudMessagingToken;
    }

    if (phoneNumber != null) {
      data['phoneNumber'] = phoneNumber;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (authProvider != null) {
      data['authProvider'] = authProvider;
    }

    if (isPhoneVerified != null) {
      data['isPhoneVerified'] = isPhoneVerified;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt?.toIso8601String();
    }

    if (lastLoginAt != null) {
      data['lastLoginAt'] = lastLoginAt?.toIso8601String();
    }

    return data;
  }

  static userModel fromMap(Map<String, dynamic> map) {
    return userModel(
      displayName: map['displayName'] != null
          ? map['displayName'] as String
          : '',
      userProfilePicUrl: map['userProfilePicUrl'] ?? '',
      userId: map['userId'] ?? '',
      cloudMessagingToken: map['cloudMessagingToken'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      authProvider: map['authProvider'] ?? '',
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
    );
  }
}
