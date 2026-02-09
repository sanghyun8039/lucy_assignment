import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/feature/logo/data/datasources/logo_local_datasource.dart';
import 'package:lucy_assignment/src/feature/logo/data/datasources/logo_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/logo/domain/repos/logo_repository.dart';

class LogoRepositoryImpl implements LogoRepository {
  final LogoRemoteDataSource _remoteDataSource;
  final LogoLocalDataSource _localDataSource;

  // 캐시 유효 기간 (체크 주기)
  static const Duration _checkInterval = Duration(days: 7);

  LogoRepositoryImpl({
    required LogoRemoteDataSource remoteDataSource,
    required LogoLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<void> syncLogos() async {
    try {
      await _localDataSource.init();

      final stocks = await _localDataSource.getStockList();
      final now = DateTime.now();

      final activeStockCodes = stocks.map((s) => s.stockCode).toSet();
      final toDownload = <dynamic>[];

      // 1. 다운로드 필요 확인 (신규, 크기 변경, 손상)
      await Future.wait(
        stocks.map((stock) async {
          final String code = stock.stockCode;
          //로컬에서 로고 데이터 있는지 확인
          final File file = await _localDataSource.getLogoFile(code);

          bool needDownload = false;

          //로컬에 파일이 없으면 다운로드
          if (!await file.exists()) {
            needDownload = true;
          } else {
            final stat = await file.stat();

            //로컬 파일이 없거나, 파일이 손상되었거나, 파일이 최신이 아니면 다운로드
            if (stat.size == 0 ||
                now.difference(stat.modified) > _checkInterval) {
              final serverSize = await _remoteDataSource.getLogoSize(code);

              if (serverSize != null) {
                if (serverSize != stat.size) {
                  needDownload = true;
                }
              } else {
                if (stat.size == 0) needDownload = true;
              }
            }
          }
          //다운로드 필요하면 추가
          if (needDownload) {
            toDownload.add(stock);
          }
        }),
      );

      // 2. 오래된 로고 정리
      final localFiles = await _localDataSource.getLocalLogos();
      for (var file in localFiles) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        final code = fileName.replaceAll('.png', '');

        if (!activeStockCodes.contains(code)) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('Failed to delete stale logo $code: $e');
          }
        }
      }

      if (toDownload.isEmpty) {
        debugPrint('All logos are up to date.');
        return;
      }

      debugPrint(
        'Syncing ${toDownload.length} logos (Size Changed or Missing)...',
      );

      // 3. 로고 다운로드 및 저장
      await Future.wait(
        toDownload.map((stock) async {
          final String code = stock.stockCode;
          try {
            //서버에서 로고 데이터 가져오기
            final bytes = await _remoteDataSource.downloadLogo(code);
            if (bytes != null && bytes.isNotEmpty) {
              //로컬에 저장
              await _localDataSource.saveLogo(code, bytes);
            }
          } catch (e) {
            debugPrint('Failed to download logo for $code: $e');
          }
        }),
      );

      debugPrint('Logo sync completed.');
    } catch (e) {
      debugPrint('Error syncing logos: $e');
    }
  }

  @override
  Future<File?> getLogoFile(String code) async {
    try {
      final file = await _localDataSource.getLogoFile(code);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
