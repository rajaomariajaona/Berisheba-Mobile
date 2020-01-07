import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumTelInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int textLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    String text = newValue.text;
    final StringBuffer textBuffer = StringBuffer();
    int usedSubString = 0;
    if (textLength >= 3) {
      textBuffer.write(text.substring(0, usedSubString = 3));
      textBuffer.write(" ");
      if (selectionIndex >= 4) selectionIndex++;
    }
    if (textLength >= 5) {
      textBuffer.write(text.substring(3, usedSubString = 5));
      textBuffer.write(" ");
      if (selectionIndex >= 7) selectionIndex++;
    }
    if (textLength >= 8) {
      textBuffer.write(text.substring(5, usedSubString = 8));
      textBuffer.write(" ");
      if (selectionIndex >= 11) selectionIndex++;
    }
    if (usedSubString < textLength)
      textBuffer.write(text.substring(usedSubString));
    return TextEditingValue(
      text: textBuffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
