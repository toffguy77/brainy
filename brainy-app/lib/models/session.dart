class Session {
  final String id;
  final int gridSize;
  final Duration time;
  final int errors;
  final DateTime date;

  const Session({
    required this.id,
    required this.gridSize,
    required this.time,
    required this.errors,
    required this.date,
  });
}
