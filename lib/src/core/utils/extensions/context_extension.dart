import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/l10n/app_localizations.dart'; // ⭐️ 자동 생성 파일 import

extension LocalizationExtension on BuildContext {
  // 's'는 String의 약자 또는 user가 사용하던 변수명
  // 'tr' (translate), 'l10n' (localization) 등으로 지어도 됩니다.
  AppLocalizations get s => AppLocalizations.of(this)!;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
