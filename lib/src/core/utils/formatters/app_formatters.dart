import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  static final comma = NumberFormat("#,###");

  // Private constructor to prevent instantiation
  AppFormatters._();
}

class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자 이외의 값은 제거
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 포맷 적용
    if (newText.isNotEmpty) {
      newText = AppFormatters.comma.format(int.parse(newText));
    }

    // 커서 위치 조정
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
