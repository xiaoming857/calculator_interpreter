import 'dart:convert';
import 'dart:io';

import 'src/ast.dart';
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
    |- Assignment                          |
    |- Function                            |
    +======================================+
  ''');

  while (true) {
    try {
      stdout.write('Enter an expression: ');
      String expression = stdin.readLineSync(encoding: utf8);
      List<List<dynamic>> tokens = Lexer.getTokens(expression);
      AST ast = Parser().parse(tokens);
      print('TOKENS: $tokens\n');
      print('AST: ${ast.toString()}\n');
    } catch (e) {
      print(e);
    }
  }
}