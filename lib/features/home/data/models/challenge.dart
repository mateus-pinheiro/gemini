class Challenge {
  Challenge(
    this.level,
    this.levelTitle,
    this.title,
    this.description,
  );

  final int level;
  final String levelTitle;
  final String title;
  final String description;
  // final ChallengeStatus? status;

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
        json['level'], json['levelTitle'], json['title'], json['description']);
  }
}
