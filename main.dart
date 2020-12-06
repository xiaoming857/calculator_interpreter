import 'dart:io';

import 'src/lexer.dart';
import 'src/parser.dart';

void main() {
  print('EXPRESSION: ');
  String expression = stdin.readLineSync();
  List<Map<TOKEN_TYPE, String>> tokens = Lexer.getTokens(expression);
  print(Parser().parse(tokens));
}