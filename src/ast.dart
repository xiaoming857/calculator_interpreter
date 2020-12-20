import 'lexer.dart';

class Node {
  @override
  String toString() {
    return 'Node()';
  }
}


class Statement extends Node {
  @override
  String toString() {
    return 'Statement';
  }
}


class Expression extends Node {
  @override
  String toString() {
    return 'Expression()';
  }
}


class Assignment extends Statement {
  Identifier _identifier;
  Node _value;

  Assignment(this._identifier, this._value);

  @override
  String toString() {
    return 'Assignemnt(${this._identifier} = ${this._value})';
  }
}


class BinaryOperation extends Expression {
  Operator _operator;
  Node _lOperand;
  Node _rOperand;

  BinaryOperation(this._operator, this._lOperand, this._rOperand);

  @override
  String toString() {
    return 'BinOp(${this._lOperand} ${this._operator} ${this._rOperand})';
  }
}


class UnaryOperation extends Expression {
  Operator _operator;
  Node _operand;

  UnaryOperation(this._operator, this._operand);

  @override
  String toString() {
    return 'UnOp(${this._operator} ${this._operand})';
  }
}


class Operator extends Node {
  TOKEN_TYPE _token;
  String _symbol;

  Operator(this._token, this._symbol);

  @override
  String toString() {
    return 'Operator(${this._symbol})';
  }
}


class Number extends Node {
  TOKEN_TYPE _token = TOKEN_TYPE.NUMBER;
  double _value;

  Number(this._value);

  @override
  String toString() {
    return 'Number(${this._value})';
  }
}


class Identifier extends Node {
  String _identifier;

  Identifier(this._identifier);

  @override
  String toString() {
    return 'Identifier(${this._identifier})';
  }
}


class AST {
  Node _root;

  AST(this._root);

  @override
  String toString() {
    return 'AST(${this._root.toString()})';
  }
}