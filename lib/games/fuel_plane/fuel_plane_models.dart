class PlaneObject {
  PlaneObject({required this.x, required this.y, required this.size, required this.type});
  double x;
  double y;
  double size;
  PlaneObjectType type;
}

enum PlaneObjectType { fuel, rock, enemy }

class PlaneBullet {
  PlaneBullet(this.x, this.y);
  double x;
  double y;
}
