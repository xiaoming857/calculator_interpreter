import 'dart:math';

import 'ast.dart';
import 'interpreter_error.dart';
import 'lexer.dart';
import 'symbol_table.dart';

class Interpreter {
  static List<InterpreterError> _errors;
  static double interpret(AST ast) {
    _errors = [];
    double result;
    if (ast.root != null) {
      if (ast.root is Declaration) {
        _visitDeclaration(ast.root);
      } else if (ast.root is Statement) {
        _visitStatement(ast.root);
      } else if (ast.root is Expression) {
        result = _visitExpression(ast.root);
      }
    }

    if (_errors.length > 0) {
      _errors.forEach((e) {
        print(e.toString());
      });
      return null;
    }

    return result;
  }


  static void _visitDeclaration(Declaration node) {
    if (node != null) {
      if (node is Function) {
        _visitFunction(node);
      }
    }
    
    return;
  }


  static void _visitStatement(Statement node) {
    if (node != null) {
      if (node is Assignment) {
        _visitAssignment(node);
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
        if (rOperandResult != 0) return lOperandResult / rOperandResult;
        _errors.add(SemanticAnalyzerError(node, (Node node) => 'Found division by zero!'));
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
    _errors.add(SemanticAnalyzerError(node, (Identifier node) => 'Identifier ${node.identifier} has not been initialized!'));

    return null;
  }


  static double _visitFunctionCall(FunctionCall node) {
    try {
      Node symbol = SymbolTable.lookUpScopes(node.identifier.identifier);
      if (symbol != null) {
        if (symbol is Function && symbol.parameters.parameters.length == node.arguments.arguments.length) {
          SemanticAnalyzerError error = SymbolTable.enterScope(SCOPE_TYPE.FUNCTION, symbol.identifier.identifier);
          if (error != null) {
            _errors.add(error);
            return null;
          }
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
      _errors.add(SemanticAnalyzerError(node, (FunctionCall node) => 'Identifier ${node.identifier.identifier} has not been initialized!'));
    } catch (e) {
      _errors.add(SemanticAnalyzerError(node, (FunctionCall node) => e.toString()));
    }
    

    return null;
  }
}