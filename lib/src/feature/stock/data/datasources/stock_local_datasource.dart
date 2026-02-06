import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';

abstract class StockLocalDataSource {
  Future<List<StockModel>> getStocks();
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  @override
  Future<List<StockModel>> getStocks() async {
    final jsonString = await rootBundle.loadString(
      'assets/jsons/stock_dumy.json',
    );
    final json = jsonDecode(jsonString);
    return (json['output'] as List<dynamic>)
        .map((e) => StockModel.fromJson(e))
        .toList();
  }
}
