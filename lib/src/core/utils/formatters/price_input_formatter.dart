import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자 이외의 값은 제거
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 포맷 적용
    if (newText.isNotEmpty) {
      newText = _formatter.format(int.parse(newText));
    }

    // 커서 위치 조정
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
