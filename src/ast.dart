import 'lexer.dart';


/// The [AST] class is the root of the tree. It stores a root node.
class AST {
  Node _root;

  AST(this._root);

  Node get root => this._root;

  @override
  String toString() {
    return 'AST(${this._root.toString()})';
  }
}


/// The [Node] class is the parent of all branches and leaf of the tree.
class Node {
  @override
  String toString() {
    return 'Node()';
  }
}


/// The [Declaration] node is the parent of all declaration typed.
class Declaration extends Node {
  @override
  String toString() {
    return 'Declaration()';
  }
}


/// The [Statement] node is the parent of all statement typed.
class Statement extends Node {
  @override
  String toString() {
    return 'Statement()';
  }
}


/// The [Expression] node is the parent of all expression typed.
class Expression extends Node {
  @override
  String toString() {
    return 'Expression()';
  }
}


/// The [Assignment] node extends [Statement] node. It stores:
/// - an [_identifier], the variable name in which an expression is assigned to
/// - an [_expression], any expression
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


/// The [Function] node extends [Declaration] node. It stores:
/// - an [_identifier], the variable name which contains the function body
/// - a [_parameters], the parameters of the function
/// - a [_expression], the body of the function
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


/// The [BinaryOperation] node extends [Expression] node. It is any binary operation.
/// A binary operation always contains a left operand, a right operand, and an operator.
/// Binary operation includes:
/// - Addition
/// - Subtraction
/// - Multiplication
/// - Division
/// - Modulo
/// - Exponential
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


/// The [UnaryOperation] node extends [Expression] node. It is any unary operation.
/// A unary operation always contains an operand and an operator.
/// Unary operation includes:
/// - Number negativity
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


/// The [Operator] node directly extends [Node]. It is any operator. It contains:
/// - [_tokenType], token type enum
/// - [_symbol], the string representational of the symbol
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


/// The [Number] node extends [Expression]. It is any literal number.
/// It contains:
/// - [_tokenType], which is always of type number
/// - [_value], the value of the number
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


/// The [Identifier] node extends [Expression]. It is any identifier (name).
/// It contains only [_identifier], which is the literal identifier (name).
class Identifier extends Expression {
  String _identifier;

  Identifier(this._identifier);

  String get identifier => this._identifier;

  @override
  String toString() {
    return 'Identifier(${this._identifier})';
  }
}


/// The [FunctionCall] node extends [Expression]. It is any function call (an identifier followed by
/// arguments between a pair of parentheses). It contains:
/// - [_identifier], the name / representation of the function
/// - [_arguments], the arguments required for the function
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


/// [Parameters] node directly extend [Node]. It contains the parameters for a function.
/// The parameters can only be identfier.
class Parameters extends Node {
  List<Identifier> _parameters;

  Parameters(this._parameters);

  List<Identifier> get parameters => this._parameters.toList();

  @override
  String toString() {
    return 'Parameters(${this._parameters})';
  }
}


/// Similar to that of a [Parameters] node. The [Arguments] node directly extend [Node]. However,
/// instead a function, it is used in a function call (different term is used for a function call).
/// The arguments can be any expressions.
class Arguments extends Node {
  List<Node> _arguments;

  Arguments(this._arguments);

  List<Node> get arguments => this._arguments.toList();

  @override
  String toString() {
    return 'Arguments(${this._arguments})';
  }
}