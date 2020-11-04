import 'package:flutter/material.dart';

class CoolText extends StatelessWidget {
  final double fontSize;
  final Color textColor;
  final String str;

  const CoolText(this.str,{Key key, this.fontSize, this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fontSize!=null && textColor != null) {
      return Text(str, style: TextStyle(color: textColor, fontSize: fontSize,));
    } else if (fontSize!=null) {
      return Text(str, style: TextStyle(fontSize: fontSize));
    } else if (textColor != null) {
      return Text(str, style: TextStyle(color: textColor));
    } else {
      return Text(str);
    }
  }
}
