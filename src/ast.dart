import 'lexer.dart';


class AST {
  Node _root;

  AST(this._root);

  Node get root => this._root;

  @override
  String toString() {
    return 'AST(${this._root.toString()})';
  }
}


class Node {
  @override
  String toString() {
    return 'Node()';
  }
}


class Declaration extends Node {
  @override
  String toString() {
    return 'Declaration()';
  }
}


class Statement extends Node {
  @override
  String toString() {
    return 'Statement()';
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
  Node _expression;

  Assignment(this._identifier, this._expression);

  Identifier get identifier => this._identifier;
  Node get expression => this._expression;

  @override
  String toString() {
    return 'Assignment(${this._identifier} = ${this._expression})';
  }
}


class Function extends Declaration {
  Identifier _identifier;
  Parameters _parameters;
  Node _expression;

  Function(this._identifier, this._parameters, this._expression);

  Identifier get identifier => this._identifier;
  Parameters get parameters => this._parameters;
  Node get expression => this._expression;

  @override
  String toString() {
    return 'Function(${this._identifier} ${this._parameters} -> ${this._expression})';
  }
}


class BinaryOperation extends Expression {
  Operator _operator;
  Node _lOperand;
  Node _rOperand;

  BinaryOperation(this._operator, this._lOperand, this._rOperand);

  Operator get operator => this._operator;
  Node get lOperand => this._lOperand;
  Node get rOperand => this._rOperand;

  @override
  String toString() {
    return 'BinOp(${this._lOperand} ${this._operator} ${this._rOperand})';
  }
}


class UnaryOperation extends Expression {
  Operator _operator;
  Node _operand;

  UnaryOperation(this._operator, this._operand);

  Operator get operator => this._operator;
  Node get operand => this._operand;

  @override
  String toString() {
    return 'UnOp(${this._operator} ${this._operand})';
  }
}


class Operator extends Node {
  TOKEN_TYPE _tokenType;
  String _symbol;

  Operator(this._tokenType, this._symbol);

  TOKEN_TYPE get tokenType => this._tokenType;
  String get symbol => this._symbol;

  @override
  String toString() {
    return 'Operator(${this._symbol})';
  }
}


class Number extends Expression {
  TOKEN_TYPE _tokenType = TOKEN_TYPE.NUMBER;
  double _value;

  Number(this._value);

  TOKEN_TYPE get token => this._tokenType;
  double get value => this._value;

  @override
  String toString() {
    return 'Number(${this._value})';
  }
}


class Identifier extends Expression {
  String _identifier;

  Identifier(this._identifier);

  String get identifier => this._identifier;

  @override
  String toString() {
    return 'Identifier(${this._identifier})';
  }
}


class FunctionCall extends Expression {
  Identifier _identifier;
  Arguments _arguments;

  FunctionCall(this._identifier, this._arguments);

  Identifier get identifier => this._identifier;
  Arguments get arguments => this._arguments;

  @override
  String toString() {
    return 'Function(${this._identifier} ${this._arguments})';
  }
}


class Parameters extends Node {
  List<Identifier> _parameters;

  Parameters(this._parameters);

  List<Identifier> get parameters => this._parameters.toList();

  @override
  String toString() {
    return 'Parameters(${this._parameters})';
  }
}


class Arguments extends Node {
  List<Node> _arguments;

  Arguments(this._arguments);

  List<Node> get arguments => this._arguments.toList();

  @override
  String toString() {
    return 'Arguments(${this._arguments})';
  }
}