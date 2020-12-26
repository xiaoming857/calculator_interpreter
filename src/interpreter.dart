import 'dart:math';

import 'ast.dart';
import 'lexer.dart';
import 'symbol_table.dart';

class Interpreter {
  static double interpret(AST ast) {
    if (ast.root != null) {
      if (ast.root is Statement) {
        _visitStatement(ast.root);
      } else if (ast.root is Expression) {
        return _visitExpression(ast.root);
      }
    }

    return null;
  }


  static void _visitStatement(Statement node) {
    if (node != null) {
      if (node is Assignment) {
        _visitAssignment(node);
      } else if (node is Function) {
        _visitFunction(node);
      }
    }

    return;
  }


  static void _visitAssignment(Assignment node) {
    double result = _visitExpression(node.expression);
    if (result != null) {
      SymbolTable.addSymbol(
        node.identifier.identifier,
        Number(result),
      );
    }

    return;
  }


  static void _visitFunction(Function node) {
    Expression expression = node.expression;
    if (expression != null) {
      SymbolTable.addSymbol(
        node.identifier.identifier,
        node,
      );
    }

    SymbolTable.showSymbols();
  }


  static double _visitExpression(Expression node) {
    if (node != null) {
      if (node is BinaryOperation) {
        return _visitBinaryOperation(node);
      } else if (node is UnaryOperation) {
        return _visitUnaryOperation(node);
      } else if (node is Number) {
        return _visitNumber(node);
      } else if (node is Identifier) {
        return _visitIdentifier(node);
      } else if (node is FunctionCall) {
        return _visitFunctionCall(node);
      }
    }

    return null;
  }


  static double _visitBinaryOperation(BinaryOperation node) {
    double lOperandResult = (node.lOperand is Expression) ? _visitExpression(node.lOperand) : null;
    double rOperandResult = (node.rOperand is Expression) ? _visitExpression(node.rOperand) : null;
    TOKEN_TYPE opr = node.operator.tokenType;

    if (lOperandResult != null && rOperandResult != null) {
      if (opr == TOKEN_TYPE.PLUS) {
        return lOperandResult + rOperandResult;
      } else if (opr == TOKEN_TYPE.MINUS) {
        return lOperandResult - rOperandResult;
      } else if (opr == TOKEN_TYPE.ASTERISK) {
        return lOperandResult * rOperandResult;
      } else if (opr == TOKEN_TYPE.SLASH) {
        if (rOperandResult == 0) throw Exception('Division by zero!');
        return lOperandResult / rOperandResult;
      } else if (opr == TOKEN_TYPE.PERCENT) {
        return lOperandResult % rOperandResult;
      } else if (opr == TOKEN_TYPE.CARET) {
        return pow(lOperandResult, rOperandResult);
      }
    }

    return null;
  }


  static double _visitUnaryOperation(UnaryOperation node) {
    double operandResult;
    if (node.operand is Expression) {
      operandResult = _visitExpression(node.operand);
    }

    if (operandResult != null) {
      if (node.operator.tokenType == TOKEN_TYPE.MINUS) {
        return -operandResult;
      }
    }

    return null;
  }


  static double _visitNumber(Number node) {
    return node.value;
  }


  static double _visitIdentifier(Identifier node) {
    Node symbol = SymbolTable.lookUpScopes(node.identifier);
    if (symbol != null) {
      if (symbol is Expression) {
        return _visitExpression(symbol);
      }
    }

    return null;
  }


  static double _visitFunctionCall(FunctionCall node) {
    Node symbol = SymbolTable.lookUpScopes(node.identifier.identifier);
    if (symbol != null) {
      if (symbol is Function && symbol.parameters.parameters.length == node.arguments.arguments.length) {
        SymbolTable.enterScope();
        int index = 0;
        symbol.parameters.parameters.forEach((e) {
          _visitAssignment(
            Assignment(
              Identifier(e.identifier),
              node.arguments.arguments[index++],
            ),
          );
        });
        double result = _visitExpression(symbol.expression);
        SymbolTable.exitScope();
        return result;
      }
    }

    return null;
  }
}