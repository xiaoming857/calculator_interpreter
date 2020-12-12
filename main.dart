import 'dart:convert';
import 'dart:io';

import 'src/lexer.dart';
import 'src/parser.dart';

void main() {
  print('''
    +======================================+
    |Supported Operations:                 |
    +--------------------------------------+
    |- Addition & Subtraction              |
    |- Multiplication & Division & Modulus |
    |- Exponential                         |
    +======================================+
  ''');
  stdout.write('Enter an expression: ');
  String expression = stdin.readLineSync(encoding: utf8);
  List<List<dynamic>> tokens = Lexer.getTokens(expression);
  print('TOKENS: $tokens\n');
  print('RESULT: ${Parser().parse(tokens).toString()}');
}