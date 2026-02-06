import 'package:hive_flutter/hive_flutter.dart';

part 'alert_type.g.dart';

@HiveType(typeId: 1, adapterName: 'AlertTypeAdapter')
enum AlertType {
  @HiveField(0)
  upper, // 목표가 이상 (상승 돌파)
  @HiveField(1)
  lower, // 목표가 이하 (하락 돌파)
  @HiveField(2)
  bidir, // 양방향
}
