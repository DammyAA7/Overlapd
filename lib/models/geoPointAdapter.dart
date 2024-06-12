import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'geoPointAdapter.g.dart';

@HiveType(typeId: 2)
class GeoPointAdapter extends HiveObject {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  GeoPointAdapter(this.latitude, this.longitude);

  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  factory GeoPointAdapter.fromGeoPoint(GeoPoint geoPoint) {
    return GeoPointAdapter(geoPoint.latitude, geoPoint.longitude);
  }
}
