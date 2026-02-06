import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 타이포그래피 시스템
///
/// Inter 폰트(Display)와 Noto Sans 폰트(Body)를 기반으로 구성
class AppTypography {
  AppTypography._();

  // ============================================================
  // Font Families
  // ============================================================

  /// Display 폰트 (제목, 헤더 등)
  static const String fontFamilyDisplay = 'Inter';

  /// Body 폰트 (본문, 일반 텍스트)
  static const String fontFamilyBody = 'Noto Sans';

  // ============================================================
  // Display Styles (큰 제목)
  // ============================================================

  /// Display Large - 가장 큰 제목
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display Medium - 중간 크기 제목
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
  );

  /// Display Small - 작은 제목
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // ============================================================
  // Headline Styles (섹션 제목)
  // ============================================================

  /// Headline Large
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  /// Headline Medium
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.15,
  );

  /// Headline Small
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  // ============================================================
  // Title Styles (카드 제목, 리스트 아이템 제목)
  // ============================================================

  /// Title Large
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Title Medium
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Title Small
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ============================================================
  // Body Styles (본문 텍스트)
  // ============================================================

  /// Body Large
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Medium
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Small
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ============================================================
  // Label Styles (버튼, 탭, 라벨)
  // ============================================================

  /// Label Large
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  /// Label Medium
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Label Small
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ============================================================
  // Special Styles (특수 용도)
  // ============================================================

  /// 가격 표시용 (Tabular Numbers)
  static const TextStyle price = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 큰 가격 표시용
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.5,
  );

  /// 퍼센트 표시용
  static const TextStyle percentage = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 심볼/티커 표시용 (대문자)
  static const TextStyle symbol = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.8,
  );
}
