class Team {
  final String id;
  final String name;
  final String? badgeUrl;

  Team({
    required this.id,
    required this.name,
    this.badgeUrl,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['idTeam'],
      name: json['strTeam'],
      badgeUrl: json['strTeamBadge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTeam': id,
      'strTeam': name,
      'strTeamBadge': badgeUrl,
    };
  }
}