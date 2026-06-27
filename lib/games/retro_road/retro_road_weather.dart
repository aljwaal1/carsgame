enum RoadWeather { day, sunset, night, fog, snow, rain }

extension RoadWeatherText on RoadWeather {
  String get label {
    switch (this) {
      case RoadWeather.day: return 'نهار';
      case RoadWeather.sunset: return 'غروب';
      case RoadWeather.night: return 'ليل';
      case RoadWeather.fog: return 'ضباب';
      case RoadWeather.snow: return 'ثلج';
      case RoadWeather.rain: return 'مطر';
    }
  }

  double get visibility {
    switch (this) {
      case RoadWeather.night: return 0.45;
      case RoadWeather.fog: return 0.32;
      case RoadWeather.rain: return 0.58;
      default: return 1.0;
    }
  }

  double get steeringMultiplier {
    switch (this) {
      case RoadWeather.snow: return 1.45;
      case RoadWeather.rain: return 1.22;
      default: return 1.0;
    }
  }
}
