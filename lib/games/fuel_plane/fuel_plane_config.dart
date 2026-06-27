class FuelPlaneConfig {
  static const double initialFuel = 100;
  static const double fuelDrain = 0.045;
  static const double fuelGain = 22;

  // Slower arcade pacing. The old values made the game feel unfair and too fast.
  static const double initialSpeed = 0.0065;
  static const double maxSpeed = 0.018;

  static const double planeY = 0.82;
  static const double moveStep = 0.075;

  static const int pointsPerDistanceTick = 1;
  static const int pointsPerFuel = 120;
  static const int pointsPerHit = 75;
}
