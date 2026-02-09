import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';
import 'package:path_provider/path_provider.dart';

abstract class LogoLocalDataSource {
  Future<void> init();
  Future<List<StockModel>> getStockList();
  Future<List<File>> getLocalLogos();
  Future<File> getLogoFile(String code);
  Future<void> saveLogo(String code, List<int> bytes);
}

class LogoLocalDataSourceImpl implements LogoLocalDataSource {
  Directory? _logoDir;

  @override
  Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _logoDir = Directory('${appDocDir.path}/logos');
    if (!await _logoDir!.exists()) {
      await _logoDir!.create(recursive: true);
    }
  }

  @override
  Future<List<StockModel>> getStockList() async {
    final jsonString = await rootBundle.loadString(
      'assets/jsons/stock_dumy.json',
    );
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return jsonData['output']
        .map<StockModel>((e) => StockModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<File>> getLocalLogos() async {
    if (_logoDir == null) await init();
    return _logoDir!.listSync().whereType<File>().toList();
  }

  @override
  Future<File> getLogoFile(String code) async {
    if (_logoDir == null) await init();
    return File('${_logoDir!.path}/$code.png');
  }

  @override
  Future<void> saveLogo(String code, List<int> bytes) async {
    final file = await getLogoFile(code);
    await file.writeAsBytes(bytes);
  }
}
