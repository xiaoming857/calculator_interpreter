import 'dart:convert';
import 'dart:io';

import 'src/ast.dart';
import 'src/lexer.dart';
import 'src/parser.dart';
import 'src/interpreter.dart';
import 'src/errors.dart';


void main() {
  print('''
    +======================================+
    |Features:                             |
    +--------------------------------------+
    |- Addition & Subtraction              |
    |- Multiplication & Division & Modulus |
    |- Exponential                         |
    |- Assignment                          |
    |- Function                            |
    |- Error Handling                      |
    +======================================+
  ''');

  while (true) {
    try {
      stdout.write('Enter an expression: ');
      String code = stdin.readLineSync(encoding: utf8);
      InterpreterError.code = code;
      List<List<dynamic>> tokens = Lexer().getTokens(code);
      AST ast = Parser().parse(tokens);
      double result = Interpreter.interpret(ast);
      print('');
      print('TOKENS: $tokens\n');
      print('AST: ${ast.toString()}\n');
      print('RESULT: $result\n\n');

      if (Errors.hasError()) {
        Errors.printErrors();
      }
      Errors.clear();

      print('');
    } catch (e) {
      print(e);
    }
  }
}