import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class LogoRemoteDataSource {
  Future<List<int>?> downloadLogo(String code);
  Future<int?> getLogoSize(String code);
}

class LogoRemoteDataSourceImpl implements LogoRemoteDataSource {
  final Dio _dio;
  final String _token = dotenv.env['LOGO_DEV_TOKEN'] ?? '';
  final String _baseUrl = 'https://img.logo.dev/ticker';

  LogoRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<int>?> downloadLogo(String code) async {
    final url = '$_baseUrl/$code.KS?token=$_token';
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      debugPrint('Failed to download logo for $code: $e');
      return null;
    }
  }

  @override
  Future<int?> getLogoSize(String code) async {
    final url = '$_baseUrl/$code.KS?token=$_token';
    try {
      final response = await _dio.head(url);
      return int.parse(response.headers.value('content-length') ?? '0');
    } catch (e) {
      debugPrint('Failed to get logo size for $code: $e');
      return null;
    }
  }
}
