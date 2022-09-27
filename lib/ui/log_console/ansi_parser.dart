import 'package:flutter/material.dart';

class AnsiParser {
  static const stateText = 0, stateBracket = 1, stateCode = 2;

  final bool dark;

  AnsiParser(this.dark);

  Color? foreground;
  Color? background;
  List<TextSpan>? spans;

  void parse(String s) {
    spans = [];
    var state = stateText;
    StringBuffer? buffer;
    var text = StringBuffer();
    var code = 0;
    List<int>? codes;

    for (var i = 0, n = s.length; i < n; i++) {
      var c = s[i];

      switch (state) {
        case stateText:
          if (c == '\u001b') {
            state = stateBracket;
            buffer = StringBuffer(c);
            code = 0;
            codes = [];
          } else {
            text.write(c);
          }
          break;

        case stateBracket:
          buffer!.write(c);
          if (c == '[') {
            state = stateCode;
          } else {
            state = stateText;
            text.write(buffer);
          }
          break;

        case stateCode:
          buffer!.write(c);
          var codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes!.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans!.add(createSpan(text.toString()));
              text.clear();
            }
            state = stateText;
            if (c == 'm') {
              codes!.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }

    spans!.add(createSpan(text.toString()));
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0, true);
        background = getColor(0, false);
        break;
      case 38:
        foreground = getColor(codes[2], true);
        break;
      case 39:
        foreground = getColor(0, true);
        break;
      case 48:
        background = getColor(codes[2], false);
        break;
      case 49:
        background = getColor(0, false);
    }
  }

  Color getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 0:
        return foreground ? Colors.black : Colors.transparent;
      case 12:
        return dark ? Colors.lightBlue.shade300 : Colors.indigo.shade700;
      case 208:
        return dark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 196:
        return dark ? Colors.red.shade300 : Colors.red.shade700;
      case 199:
        return dark ? Colors.pink.shade300 : Colors.pink.shade700;
    }
    return foreground ? Colors.black : Colors.transparent;
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
