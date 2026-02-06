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
}
