class FootballDataMatch {
  final String homeTeam;
  final String awayTeam;
  final DateTime utcDate;
  final String? status;

  FootballDataMatch({
    required this.homeTeam,
    required this.awayTeam,
    required this.utcDate,
    this.status,
  });

  factory FootballDataMatch.fromJson(Map<String, dynamic> json) {
    return FootballDataMatch(
      homeTeam: json['homeTeam']['name'] ?? 'Unknown',
      awayTeam: json['awayTeam']['name'] ?? 'Unknown',
      utcDate: DateTime.parse(json['utcDate']),
      status: json['status'],
    );
  }
}