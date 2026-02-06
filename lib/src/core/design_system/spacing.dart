/// 앱 전체에서 사용되는 간격 시스템
///
/// 4px 배수 기준으로 일관된 간격을 제공
class AppSpacing {
  AppSpacing._();

  // ============================================================
  // Base Spacing (4px 단위)
  // ============================================================

  /// 최소 간격 (4px)
  static const double xs = 4.0;

  /// 작은 간격 (8px)
  static const double sm = 8.0;

  /// 기본 간격 (12px)
  static const double md = 12.0;

  /// 중간 간격 (16px)
  static const double lg = 16.0;

  /// 큰 간격 (24px)
  static const double xl = 24.0;

  /// 매우 큰 간격 (32px)
  static const double xxl = 32.0;

  /// 초대형 간격 (48px)
  static const double xxxl = 48.0;

  // ============================================================
  // Semantic Spacing (용도별)
  // ============================================================

  /// 화면 좌우 패딩 (16px)
  static const double screenHorizontal = 16.0;

  /// 화면 상하 패딩 (16px)
  static const double screenVertical = 16.0;

  /// 카드 내부 패딩 (16px)
  static const double cardPadding = 16.0;

  /// 리스트 아이템 간격 (12px)
  static const double listItemGap = 12.0;

  /// 섹션 간격 (24px)
  static const double sectionGap = 24.0;

  /// 버튼 내부 패딩 (세로: 12px, 가로: 24px)
  static const double buttonPaddingVertical = 12.0;
  static const double buttonPaddingHorizontal = 24.0;

  /// 아이콘과 텍스트 사이 간격 (8px)
  static const double iconTextGap = 8.0;

  /// 하단 네비게이션 바 높이 (64px)
  static const double bottomNavHeight = 64.0;

  /// 앱바 높이 (56px)
  static const double appBarHeight = 56.0;

  /// 탭 바 높이 (48px)
  static const double tabBarHeight = 48.0;
}
