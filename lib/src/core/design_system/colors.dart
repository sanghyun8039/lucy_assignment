import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 팔레트
///
/// design 폴더의 HTML 파일들에서 추출한 색상 체계를 기반으로 구성
class AppColors {
  AppColors._();

  // ============================================================
  // Primary Colors
  // ============================================================

  /// 주요 브랜드 컬러 (파란색)
  /// 사용처: 액션 버튼, 선택된 탭, 링크 등
  static const Color primary = Color(0xFF197FE6);

  // ============================================================
  // Background Colors
  // ============================================================

  /// 라이트 모드 배경색
  static const Color backgroundLight = Color(0xFFF6F7F8);

  /// 다크 모드 배경색
  static const Color backgroundDark = Color(0xFF111921);

  /// 다크 모드 Surface 색상 (카드, 패널 등)
  static const Color surfaceDark = Color(0xFF1C2936);

  /// 다크 모드 Surface 색상 - 변형 1
  static const Color surfaceDark2 = Color(0xFF1C1E24);

  /// 다크 모드 Surface 색상 - 변형 2
  static const Color surfaceDark3 = Color(0xFF1E2933);

  // ============================================================
  // Semantic Colors (금융 앱 특화)
  // ============================================================

  /// 상승/증가를 나타내는 색상 (빨간색)
  /// 사용처: 주가 상승, 수익률 증가 등
  static const Color growth = Color(0xFFEF4444);

  /// 상승/증가를 나타내는 색상 - 변형 1
  static const Color growth2 = Color(0xFFFF453A);

  /// 상승/증가를 나타내는 색상 - 변형 2
  static const Color growth3 = Color(0xFFFF3B30);

  /// 하락/감소를 나타내는 색상 (파란색)
  /// 사용처: 주가 하락, 손실 등
  static const Color decline = Color(0xFF091CE9);

  /// 하락/감소를 나타내는 색상 - 변형
  static const Color decline2 = Color(0xFF197FE6);

  // ============================================================
  // Text Colors
  // ============================================================

  /// 보조 텍스트 색상 (라벨, 캡션 등)
  static const Color textSecondary = Color(0xFF93ADC8);

  /// 라이트 모드 주요 텍스트
  static const Color textPrimaryLight = Color(0xFF1E293B);

  /// 다크 모드 주요 텍스트
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  // ============================================================
  // Border Colors
  // ============================================================

  /// 기본 테두리 색상
  static const Color border = Color(0xFF344D65);

  /// 라이트 모드 테두리
  static const Color borderLight = Color(0xFFE2E8F0);

  /// 다크 모드 테두리
  static const Color borderDark = Color(0xFF334155);

  // ============================================================
  // Utility Colors
  // ============================================================

  /// 반투명 오버레이 (다크)
  static const Color overlayDark = Color(0x80000000);

  /// 반투명 오버레이 (라이트)
  static const Color overlayLight = Color(0x40FFFFFF);

  /// 에러 색상
  static const Color error = Color(0xFFDC2626);

  /// 성공 색상
  static const Color success = Color(0xFF10B981);

  /// 경고 색상
  static const Color warning = Color(0xFFF59E0B);

  /// 정보 색상
  static const Color info = Color(0xFF3B82F6);
}
