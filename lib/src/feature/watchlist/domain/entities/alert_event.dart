import 'package:lucy_assignment/src/core/constants/alert_type.dart';

class AlertEvent {
  final String stockName;
  final int targetPrice;
  final AlertType type;
  final String stockCode;

  AlertEvent({
    required this.stockName,
    required this.targetPrice,
    required this.type,
    required this.stockCode,
  });
}
