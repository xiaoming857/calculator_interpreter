import 'dart:math';

import 'ast.dart';
import 'errors.dart';
import 'lexer.dart';
import 'symbol_table.dart';


/// The [Interpreter] class is where semantic analysis is done as well as the process of calculating the result.
class Interpreter {
  /// The [interpret] method is called to run the process. It accepts an [AST] and returns a double if the calculation
  /// is successful, otherwise a null. 
  static double interpret(AST ast) {
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

    return Errors.hasError() ? null : result;
  }


  /// [_visitDeclaration] is called if there is a [Declaration] node or its children in the ast
  static void _visitDeclaration(Declaration node) {
    if (node != null) {
      if (node is Function) {
        _visitFunction(node);
      }
    }
    
    return;
  }


  /// [_visitStatement] is called if there is a [Statement] node or its children in the ast
  static void _visitStatement(Statement node) {
    if (node != null) {
      if (node is Assignment) {
        _visitAssignment(node);
      }
    }

    return;
  }


  /// [_visitAssignment] is called if there is a [Assignment] node if its children in the ast
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


  /// [_visitFunction] is called if there is a [Function] node or its children in the ast 
  static void _visitFunction(Function node) {
    Expression expression = node.expression;
    if (expression != null) {
      SymbolTable.addSymbol(
        node.identifier.identifier,
        node,
      );
    }
  }


  /// [_visitExpression] is called if there is an [Expression] node or its children in the ast
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


  /// [_visitBinaryOperation] is called if there is a [BinaryOperation] node or its children in the ast
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
        Errors.addError(SemanticAnalyzerError(node, (Node node) => 'Invalid division by zero!'));
      } else if (opr == TOKEN_TYPE.PERCENT) {
        return lOperandResult % rOperandResult;
      } else if (opr == TOKEN_TYPE.CARET) {
        if (lOperandResult < 0 && rOperandResult % 1 != 0) {
          Errors.addError(SemanticAnalyzerError(node, (Node node) => 'Invalid root for negative numbers!'));
          return null;
        }
        return pow(lOperandResult, rOperandResult);
      }
    }

    return null;
  }


  /// [_visitUnaryOperation] is called if there is a [UnaryOperation] node or its children in the ast
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


  /// [Number] is called if there is a [Number] node or its children in the ast
  static double _visitNumber(Number node) {
    return node.value;
  }


  /// [_visitIdentifier] is called if there is a [Identifier] node or its children in the ast
  static double _visitIdentifier(Identifier node) {
    Node symbol = SymbolTable.lookUpScopes(node.identifier);
    if (symbol != null) {
      if (symbol is Expression) {
        return _visitExpression(symbol);
      }
    }
    Errors.addError(SemanticAnalyzerError(node, (Identifier node) => 'Identifier ${node.identifier} has not been initialized!'));

    return null;
  }


  /// [_visitFunctionCall] is called if there is a [FunctionCall] node or its children in the ast
  static double _visitFunctionCall(FunctionCall node) {
    try {
      Node symbol = SymbolTable.lookUpScopes(node.identifier.identifier);
      if (symbol != null) {
        if (symbol is Function && symbol.parameters.parameters.length == node.arguments.arguments.length) {
          SemanticAnalyzerError error = SymbolTable.enterScope(SCOPE_TYPE.FUNCTION, symbol.identifier.identifier);
          if (error != null) {
            Errors.addError(error);
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
      Errors.addError(SemanticAnalyzerError(node, (FunctionCall node) => 'Identifier ${node.identifier.identifier} has not been initialized!'));
    } catch (e) {
      Errors.addError(SemanticAnalyzerError(node, (FunctionCall node) => e.toString()));
    }
    

    return null;
  }
}