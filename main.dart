import 'dart:io';

import 'src/lexer.dart';

void main() {
  print('EXPRESSION: ');
  String expression = stdin.readLineSync();
  getToken(expression)?.forEach((element) {print(element);});
}