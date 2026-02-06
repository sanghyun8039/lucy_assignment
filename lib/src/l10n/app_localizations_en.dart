// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get markets => 'Markets';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get searchBarPlaceholder => 'Search for stocks, ETFs, etc.';
}
