import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class PriceSection extends StatefulWidget {
  final StockEntity initialStock;
  final Stream<StockSocketMessage> priceStream;

  const PriceSection({
    super.key,
    required this.initialStock,
    required this.priceStream,
  });

  @override
  State<PriceSection> createState() => _PriceSectionState();
}

class _PriceSectionState extends State<PriceSection>
    with AutomaticKeepAliveClientMixin {
  final List<FlSpot> _spots = [];
  final List<DateTime> _timestamps = [];
  late StreamSubscription<StockSocketMessage> _subscription;

  double _currentPrice = 0;
  double _changeRate = 0;

  // X axis counter for simulated time progression
  double _xValue = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.initialStock.currentPrice.toDouble();
    _changeRate = widget.initialStock.changeRate;

    // Initialize with a starting point
    _spots.add(FlSpot(_xValue, _currentPrice));
    _timestamps.add(widget.initialStock.timestamp ?? DateTime.now());

    _subscription = widget.priceStream.listen((message) {
      if (!mounted) return;
      setState(() {
        _currentPrice = message.currentPrice;
        _changeRate = message.changeRate;

        _xValue += 1;
        _spots.add(FlSpot(_xValue, _currentPrice));
        _timestamps.add(message.timestamp);

        // Keep a window of data points (e.g., last 50) to keep chart moving
        if (_spots.length > 50) {
          _spots.removeAt(0);
          if (_timestamps.isNotEmpty) {
            _timestamps.removeAt(0);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isRising = _changeRate >= 0;
    final color = isRising ? AppColors.growth : AppColors.decline;
    final icon = isRising ? Icons.trending_up : Icons.trending_down;
    final prefix = isRising ? '+' : '';

    final double prevPrice = _currentPrice / (1 + (_changeRate / 100));
    final int changeValue = (_currentPrice - prevPrice).round();

    final currencyFormat = NumberFormat("#,###");

    double minY = _currentPrice;
    double maxY = _currentPrice;
    if (_spots.isNotEmpty) {
      minY = _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      maxY = _spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    }
    // Add some padding
    final double padding = (maxY - minY) * 0.1;
    if (padding == 0) {
      minY = _currentPrice * 0.99;
      maxY = _currentPrice * 1.01;
    } else {
      minY -= padding;
      maxY += padding;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.currentPrice,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Gap(4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencyFormat.format(_currentPrice),
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 36.sp,
                ),
              ),
              Gap(8),
              Text(
                "KRW",
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(8),
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              Gap(4),
              Text(
                "$prefix${currencyFormat.format(changeValue)} KRW ($prefix${_changeRate.toStringAsFixed(2)}%)",
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(32),

          SizedBox(
            height: 220.h,
            width: double.infinity,
            child: IgnorePointer(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40.w, // 라벨 공간 확보
                        getTitlesWidget: (value, meta) {
                          // value가 Y축 값(가격)입니다.
                          if (value == minY || value == maxY)
                            return const SizedBox.shrink(); // 최소/최대값은 겹칠 수 있어서 숨김 처리(선택사항)

                          String text;
                          if (value >= 1000) {
                            final formattedValue = NumberFormat(
                              "#,###",
                            ).format(value.toInt() / 1000);
                            text = '${formattedValue}k';
                          } else {
                            text = NumberFormat("#,###").format(value.toInt());
                          }

                          return Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: _spots.first.x,
                  maxX: _spots.last.x,
                  minY: minY,
                  maxY: maxY,

                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3.w,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(
                    enabled: false,
                  ), // Disable touch for simple view
                ),
                duration: Duration.zero, // Instant update for real-time feel
              ),
            ),
          ),

          // Time Labels
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildTimeLabels(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeLabels() {
    if (_timestamps.isEmpty) return [];

    final dateFormat = DateFormat('HH:mm:ss');
    final labels = <Widget>[];

    // precision: 4 labels
    final int count = 4;
    final int len = _timestamps.length;

    if (len < count) {
      // Not enough data, just show what we have or fill
      for (var t in _timestamps) {
        labels.add(_TimeLabel(dateFormat.format(t)));
      }
    } else {
      // Start
      labels.add(_TimeLabel(dateFormat.format(_timestamps.first)));

      // 1/3
      int index1 = (len * 0.33).round();
      if (index1 >= len) index1 = len - 1;
      labels.add(_TimeLabel(dateFormat.format(_timestamps[index1])));

      // 2/3
      int index2 = (len * 0.66).round();
      if (index2 >= len) index2 = len - 1;
      labels.add(_TimeLabel(dateFormat.format(_timestamps[index2])));

      // End
      labels.add(_TimeLabel(dateFormat.format(_timestamps.last)));
    }

    return labels;
  }
}

class _TimeLabel extends StatelessWidget {
  final String text;
  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 10.sp,
      ),
    );
  }
}
