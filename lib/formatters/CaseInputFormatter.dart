import 'package:flutter/services.dart';
import 'package:strings/strings.dart';

class ToUpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int selectionIndex = newValue.selection.end;
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class CapitalizeWordsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int selectionIndex = newValue.selection.end;
    String text = newValue.text;
    List<String> words = text.split(" ");
    text = words
        .map((word) {
          return capitalize(word.toLowerCase());
        })
        .toList()
        .join(" ");
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
