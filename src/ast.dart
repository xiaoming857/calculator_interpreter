import 'lexer.dart';

class Node {
  @override
  String toString() {
    return 'Node()';
  }
}


class Expression extends Node {
  Operator opr;
  Node lValue;
  Node rValue;

  Expression(this.opr, this.lValue, this.rValue);
  @override
  String toString() {
    return 'Expr(${this.lValue} ${this.opr} ${this.rValue})';
  }
}


class BinaryOperation extends Expression {
  BinaryOperation(Operator opr, Node lValue, Node rValue) : super(opr, lValue, rValue);

  @override
  String toString() {
    return 'BinOp(${super.lValue} ${super.opr} ${super.rValue})';
  }
}


class UnaryOperation extends BinaryOperation {
  UnaryOperation(Operator opr, rValue) : super (opr, null, rValue);

  @override
  String toString() {
    return 'UnOp(${super.opr} ${super.rValue})';
  }
}


class Operator extends Node {
  TOKEN_TYPE token;
  String symbol;

  Operator(this.token, this.symbol);

  @override
  String toString() {
    return 'Operator(${this.symbol})';
  }
}


class Number extends Node {
  TOKEN_TYPE token = TOKEN_TYPE.NUMBER;
  double value;

  Number(this.value);

  @override
  String toString() {
    return 'Number(${this.value})';
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