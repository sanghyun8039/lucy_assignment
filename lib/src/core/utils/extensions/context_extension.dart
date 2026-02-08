import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/l10n/app_localizations.dart'; // ⭐️ 자동 생성 파일 import

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
