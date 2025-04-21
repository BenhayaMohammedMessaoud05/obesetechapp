class ActivityData {
  final int steps;
  final int calories;
  final double kilometers;
  final int activeMinutes;
  final int goalPercent;
  final List<int> weeklySteps; // [Mon, Tue, Wed, ...]

  ActivityData({
    required this.steps,
    required this.calories,
    required this.kilometers,
    required this.activeMinutes,
    required this.goalPercent,
    required this.weeklySteps,
  });
}
