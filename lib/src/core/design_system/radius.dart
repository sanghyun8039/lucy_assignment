import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 Border Radius 시스템
///
/// design 폴더의 HTML에서 추출한 Border Radius 값들을 기반으로 구성
class AppRadius {
  AppRadius._();

  // ============================================================
  // Radius Values
  // ============================================================

  /// 기본 (4px)
  static const double sm = 4.0;

  /// 중간 (8px)
  static const double md = 8.0;

  /// 큰 (12px)
  static const double lg = 12.0;

  /// 매우 큰 (16px)
  static const double xl = 16.0;

  /// 초대형 (24px)
  static const double xxl = 24.0;

  /// 완전한 원형 (9999px)
  static const double full = 9999.0;

  // ============================================================
  // BorderRadius Objects
  // ============================================================

  /// 기본 BorderRadius (4px)
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

  /// 중간 BorderRadius (8px)
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));

  /// 큰 BorderRadius (12px)
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));

  /// 매우 큰 BorderRadius (16px)
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));

  /// 초대형 BorderRadius (24px)
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));

  /// 완전한 원형 BorderRadius
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );

  // ============================================================
  // Semantic BorderRadius (용도별)
  // ============================================================

  /// 버튼 BorderRadius (8px)
  static const BorderRadius button = borderMd;

  /// 카드 BorderRadius (12px)
  static const BorderRadius card = borderLg;

  /// 입력 필드 BorderRadius (8px)
  static const BorderRadius input = borderMd;

  /// 칩/태그 BorderRadius (완전한 원형)
  static const BorderRadius chip = borderFull;

  /// 다이얼로그 BorderRadius (16px)
  static const BorderRadius dialog = borderXl;

  /// 바텀 시트 BorderRadius (상단만 16px)
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}
