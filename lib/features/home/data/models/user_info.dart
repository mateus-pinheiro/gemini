class UserInfo {
  final int? level;
  final String? name;

  UserInfo({this.level, this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(level: json["level"], name: json["name"]);
  }
}
