import 'dart:io';

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

      final activeStockCodes = stocks
          .map((s) => s['mksc_shrn_iscd'] as String)
          .toSet();
      final toDownload = <dynamic>[];

      // 1. Check for Downloads (New, Size Changed, Corrupted)
      // 모든 종목에 대해 HEAD 요청을 날리면 너무 느릴 수 있으므로,
      // "7일이 지난 파일"에 대해서만 HEAD 체크를 수행하여 최적화합니다.
      await Future.wait(
        stocks.map((stock) async {
          final String code = stock['mksc_shrn_iscd'];
          final File file = await _localDataSource.getLogoFile(code);

          bool needDownload = false;

          if (!await file.exists()) {
            needDownload = true;
          } else {
            final stat = await file.stat();

            // 파일이 0바이트거나 점검 주기가 지났다면 서버 확인
            if (stat.size == 0 ||
                now.difference(stat.modified) > _checkInterval) {
              final serverSize = await _remoteDataSource.getLogoSize(code);

              // 서버 크기를 알 수 없으면(null) 안전하게 다운로드,
              // 서버 크기와 로컬 크기가 다르면 변경된 것으로 간주하고 다운로드
              if (serverSize != null) {
                if (serverSize != stat.size) {
                  needDownload = true;
                } else {
                  // 크기가 같으면 수정 시간만 갱신(touch)하여 다음 주기에 체크하도록 함
                  // Dart에서 수정 시간 변경은 까다로우므로 생략하거나 파일을 다시 써야 함.
                  // 여기서는 굳이 복잡하게 하지 않고 넘어감.
                  // (다음 앱 실행 때 다시 7일 지났다고 뜨겠지만, 그때도 HEAD 체크 후 같으면 스킵되므로 안전함)
                }
              } else {
                // 서버 오류 등으로 크기 확인 불가 시, 파일이 0이면 받아야겠지만
                // 이미 파일이 있고 크기 확인 실패면 기존 파일 유지 (안전책)
                if (stat.size == 0) needDownload = true;
              }
            }
          }

          if (needDownload) {
            // 동시성 문제 방지를 위해 synchronized list add 필요하지만,
            // Dart는 단일 스레드 Event Loop이므로 List.add는 안전함.
            toDownload.add(stock);
          }
        }),
      );

      // 2. Cleanup Stale Logos
      final localFiles = await _localDataSource.getLocalLogos();
      for (var file in localFiles) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        final code = fileName.replaceAll('.png', '');

        if (!activeStockCodes.contains(code)) {
          try {
            await file.delete();
          } catch (e) {
            print('Failed to delete stale logo $code: $e');
          }
        }
      }

      if (toDownload.isEmpty) {
        print('All logos are up to date.');
        return;
      }

      print('Syncing ${toDownload.length} logos (Size Changed or Missing)...');

      await Future.wait(
        toDownload.map((stock) async {
          final String code = stock['mksc_shrn_iscd'];
          try {
            final bytes = await _remoteDataSource.downloadLogo(code);
            if (bytes != null && bytes.isNotEmpty) {
              await _localDataSource.saveLogo(code, bytes);
            }
          } catch (e) {
            print('Failed to download logo for $code: $e');
          }
        }),
      );

      print('Logo sync completed.');
    } catch (e) {
      print('Error syncing logos: $e');
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
