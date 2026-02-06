// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get markets => '시장';

  @override
  String get noResultsFound => '검색 결과가 없습니다.';

  @override
  String get searchBarPlaceholder => '종목, ETF, 등 검색';

  @override
  String get currentPrice => '현재가';

  @override
  String get alertCondition => '알림 조건';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get targetPrice => '타겟가';

  @override
  String get upper => '상승';

  @override
  String get lower => '하락';

  @override
  String get bidir => '양방향';

  @override
  String get addToWatchlist => '관심종목 추가';
}
