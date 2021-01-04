import 'dart:convert';
import 'dart:io';

import 'src/ast.dart';
import 'src/lexer.dart';
import 'src/parser.dart';
import 'src/interpreter.dart';

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
      String code = stdin.readLineSync(encoding: utf8);
      List<List<dynamic>> tokens = Lexer.getTokens(code);
      AST ast = Parser().parse(tokens, code);
      double result = Interpreter.interpret(ast);
      print('TOKENS: $tokens\n');
      print('AST: ${ast.toString()}\n');
      print('RESULT: $result');
    } catch (e) {
      print(e);
    }
  }
}