import 'lexer.dart';
import 'ast.dart';
import 'errors.dart';


/// The [Parser] is used for syntax analysis, one of the stage in an interpreter.
/// It receives a list of tokens and generates an ast tree used for semantic analysis.
/// The parser itself uses top down LL(1) recursive decent parser.
class Parser {
  /// The [_tokens] is used to temporarily hold the inputted tokens which will be used in methods
  /// within the class.
  List<List<dynamic>> _tokens;

  /// The [_index] shows the current position of the parse. It starts with -1, everytime a parse/method is called,
  /// it will be incremented by 1. If the parse/method is incorrect, the [_index] will be decremented by 1.
  int _index = -1;


  /// The [parse] method is called to parse the list of tokens. It receives a list of tokens and returns
  /// a parse tree if no errors occured.
  AST parse(List<List<dynamic>> tokens) {
    this._tokens = tokens;
    return AST(this._pStart());
  }
  

  /// The [_mustBe] method is used to skip a certain invalid tokens until an expected token appears or
  /// reached [EOF].
  void _mustBe(List<TOKEN_TYPE> tokenTypes) {
    List<dynamic>token = this._tokens[this._index];
    while (!tokenTypes.contains(token[0]) && token[0] != TOKEN_TYPE.EOF) {
      Errors.addError(ParserError(token, (String t, int s, int e) => 'Unexpected ${t} at index [${s}:${e}]!'));
      token = this._tokens[++this._index];
    }
    --this._index;
  }


  /// The [_expect] method expects the next token. [_index] will not be incremented if the next token
  /// matches the expectation, it will only returns a true. Otherwise, an error will be added into the
  /// [Errors] class and a false will be returned from the method. 
  bool _expect(TOKEN_TYPE tokenType) {
    List<dynamic> token = this._tokens[this._index + 1];
    if (token[0] == tokenType) return true;
    Errors.addError(ParserError(token, (String t, int s, int e) => 'Unexpected ${t} at index [${s}:${e}]! it is expected to have token [$tokenType]!'));
    return false;
  }


  /// The [_peek] method is used to peek the next token. Unlike [_expect], [_peek] simply return true if
  /// it matches the expectation, else it will return a false.
  bool _peek(TOKEN_TYPE token, [step = 1]) {
    return (this._tokens[this._index + step][0] == token);
  }


  /// The [_pStart] method is used to determine if a the input is a declaration,
  /// statement, or an expression and then checks if it ends with an [EOF].
  /// It will skip the parser if the token starts with an [EOF].
  Node _pStart() {
    if (this._peek(TOKEN_TYPE.EOF)) return null;
    Node tree = this._pDeclaration();
    if (tree == null && !Errors.hasType<ParserError>()) tree = this._pStatement();
    if (tree == null && !Errors.hasType<ParserError>()) tree = this._pExpression();
    this._expect(TOKEN_TYPE.EOF);
    
    return (Errors.hasError()) ? null : tree;
  }


  /// The [_pDeclaration] is used to parse function declarations. A function must starts
  /// with a [func] keyword, followed by a function name, at least one parameter within
  /// a pair of parentheses, an arrow, and finally the expression.
  Node _pDeclaration() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.FUNCTION) {
      Identifier identifier = this._pIdentifier();
      if (identifier == null) {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected a function name after ${t} of index [${s}:${e}]!'));
      } else {
        token = this._tokens[this._index];
      }

      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        token = this._tokens[++this._index];
        if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
          
        }
      } else {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected an open parenthesis after ${t} of index [${s}:${e}]!'));
      }

      Parameters parameters = this._pParameter();
      if (parameters == null) {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected a parameter after ${t} of index [${s}:${e}]!'));
      } else {
        token = this._tokens[this._index];
      }

      if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
        token = this._tokens[++this._index];
      } else {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected a close parenthesis after ${t} of index [${s}:${e}]!'));
      }

      if (this._peek(TOKEN_TYPE.ARROW)) {
        token = this._tokens[++this._index];
      } else {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected an arrow after ${t} of index [${s}:${e}]!'));
      }


      Node expression = this._pExpression();
      if (expression != null) {
        return Function(
          identifier,
          parameters,
          expression,
        );
      } else {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected an expression after ${t} of index [${s}:${e}]!'));
      }
      return null;
    }
    --this._index;
    return null;
  }

  
  /// The [_pStatement] is used to parse any assignment statements. A statement starts with
  /// a variable name, followed by an equal sign and the expression to be assigned to the variable.
  Node _pStatement() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.IDENTIFIER && this._peek(TOKEN_TYPE.EQUAL)) {
      ++this._index;
      if (this._peek(TOKEN_TYPE.EOF)) {
        Errors.addError(ParserError(this._tokens[this._index], (String t, int s, int e) => 'Expected an expression after ${t} of index [${s}:${e}]'));
      } else {
        Node expression = this._pExpression();
        if (expression != null) {
          return Assignment(
            Identifier(token[1]),
            expression,
          );
        }
      }
      return null;
    }
    --this._index;
    return null;
  }


  /// The [_pExpression] is used to parse expressions, it starts with the lowest precedence,
  /// which is addition and subtraction.
  Node _pExpression() {
    Node lVal = this._pTerm();
    if (lVal != null) {
      Node rCalc = this._pExpressionPrime(lVal);
      if (rCalc != null) {
        return rCalc;
      }
      return lVal;
    } else if (!this._peek(TOKEN_TYPE.EOF)) {
      this._pExpressionPrime(lVal);
    }
    return null;
  }


  /// The [_pExpressionPrime] is a right recursion for [_pExpression]. It implements the left
  /// associativity.
  Node _pExpressionPrime(Node lVal) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.PLUS || token[0] == TOKEN_TYPE.MINUS) {
      Node rVal = this._pTerm();
      if (rVal != null) {
        Node rCalc = this._pExpressionPrime(BinaryOperation(Operator(token[0], token[1]), lVal, rVal));
        return (rCalc != null) ? rCalc : BinaryOperation(
          Operator(token[0], token[1]),
          lVal,
          rVal,
        );
      } else if (!this._peek(TOKEN_TYPE.EOF)) {
        this._pExpressionPrime(lVal);
      }
      return rVal;
    } else if (token[0] == TOKEN_TYPE.NUMBER || token[0] == TOKEN_TYPE.IDENTIFIER) {
      this._mustBe([TOKEN_TYPE.PLUS, TOKEN_TYPE.MINUS, TOKEN_TYPE.ASTERISK, TOKEN_TYPE.SLASH, TOKEN_TYPE.PERCENT, TOKEN_TYPE.CARET, TOKEN_TYPE.CLOSE_PARENTHESIS]);
      this._pExpressionPrime(lVal);
      ++this._index;
    } 
    --this._index;
    return null;
  }


  /// [_pTerm] is the next level precedence which covers multiplication, division, and
  /// modulo parse.
  Node _pTerm() {
    Node lVal = this._pPower();
    if (lVal != null) {
      Node rCalc = this._pTermPrime(lVal);
      if (rCalc != null) return rCalc;
      return lVal;
    }
    return null;
  }


  /// [_pTermPrime] is the right recursion for [_pTerm]. It implements the left associativity.
  Node _pTermPrime(Node lVal) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.ASTERISK || token[0] == TOKEN_TYPE.SLASH || token[0] == TOKEN_TYPE.PERCENT) {
      Node rVal = this._pPower();
      if (rVal != null) {
        Node rCalc = this._pTermPrime(BinaryOperation(Operator(token[0], token[1]), lVal, rVal));
        return (rCalc != null) ? rCalc : BinaryOperation(
          Operator(token[0], token[1]),
          lVal,
          rVal,
        );
      }
      return rVal;
    }
    --this._index;
    return null;
  }


  /// The [_pPower] is a higher precedence in the arithmetic operation, which covers only
  /// exponential parse.  
  Node _pPower() {
    Node lVal = this._pFactor();
    if (lVal != null) {
      Node rCalc = this._pPowerPrime(lVal);
      if (rCalc != null) return rCalc;
      return lVal;
    }
    return null;
  }


  /// The [_pPowerPrime] is the right recurssion for [_pPower]. Contrasting to [_pExpressionPrime]
  /// and [_pTermPrime], [_pPower] implements a right associativity. So,
  /// 
  /// 1 ^ 2 ^ 3
  /// is equal to:
  /// (1 ^ (2 ^ 3))
  Node _pPowerPrime(Node lVal) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.CARET) {
      Node rVal = this._pFactor();
      if (rVal != null) {
        Node rCalc = this._pPowerPrime(rVal);
        if (rCalc != null) {
          return BinaryOperation(
            Operator(token[0], token[1]),
            lVal,
            rCalc,
          );
        }
        return BinaryOperation(
          Operator(token[0], token[1]),
          lVal,
          rVal,
        );
      }
      return rVal;
    }
    --this._index;
    return null;
  }


  /// The [_pFactor] is in fact the last parse for an expression. It will be either
  /// an unary operation, a number, an identifier, or possibly an open parenthesis which
  /// leads to a higher precedence.
  Node _pFactor() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.NUMBER) {
      return Number(double.parse(token[1]));
    } else if (token[0] == TOKEN_TYPE.MINUS) {
      return UnaryOperation(
        Operator(token[0], token[1]),
        this._pFactor(),
      );
    } else if (token[0] == TOKEN_TYPE.OPEN_PARENTHESIS) {
      if (_peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
        ++this._index;
        return null;
      }
      Node rCalc = this._pExpression();
      if (rCalc != null) {
        if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
          ++this._index;
          return rCalc;
        }
      } else {
        Errors.addError(ParserError(token, (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
        this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
      }
      return null;
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      Node rCalc = Identifier(token[1]);
      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        ++this._index;
        if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
          Errors.addError(ParserError(this._tokens[this._index], (String t, int s, int e) => 'Expected an argument after token $t of index [${s}:${e}]!'));
          ++this._index;
          return null;
        }
        Node arguments = this._pArgument();
        if (arguments != null) {
          if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
            ++this._index;
            rCalc = FunctionCall(rCalc, arguments);
          }
        } else {
          Errors.addError(ParserError(this._tokens[this._index], (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
          this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
        }
      }
      return rCalc;
    }

    this._mustBe([TOKEN_TYPE.NUMBER, TOKEN_TYPE.IDENTIFIER, TOKEN_TYPE.OPEN_PARENTHESIS, TOKEN_TYPE.MINUS]);
    if (!this._peek(TOKEN_TYPE.EOF)) {
      return this._pExpression();
    } 
    Errors.addError(ParserError(this._tokens[this._index + 1], (String t, int s, int e) => 'Unexpected $t at index [${s}:${e}]!'));
    return null;    
  }


  /// The [_pParameter] is used to parse parameters which are divided by commas.
  /// It might seems similar to [_pArgument]. However, the [_pParameter] is
  /// the term used in function. The parameter can only be in the form of an identifier.
  Node _pParameter() {
    Identifier parameter = this._pIdentifier();
    List<Identifier> parameters = [];
    if (parameter != null) {
      parameters.add(parameter);
      this._pParameterPrime(parameters);
      return Parameters(parameters);
    }
    return null;
  }


  /// The [_pParameterPrime] is the right recursion for [_pParameter]
  void _pParameterPrime(List<Identifier> parameters) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.COMMA) {
      Node parameter = this._pIdentifier();
      if (parameter != null) {
        parameters.add(parameter);
        this._pArgumentPrime(parameters);
      } else {
        Errors.addError(ParserError(this._tokens[this._index], (String t, int s, int e) => 'Expect argument after comma of index [${s}:${e}]!'));
      }
      return;
    } else if (token[0] != TOKEN_TYPE.COMMA && token[0] != TOKEN_TYPE.CLOSE_PARENTHESIS && token[0] != TOKEN_TYPE.ARROW && token[0] != TOKEN_TYPE.EOF) {
      this._mustBe([TOKEN_TYPE.COMMA, TOKEN_TYPE.CLOSE_PARENTHESIS, TOKEN_TYPE.ARROW]);
      this._pParameterPrime(parameters);
      return;
    }

    --this._index;
    return;
  }


  /// The [_pArgument] is used to parse arguments which are divided by commas.
  /// It might seems similar to [_pParameter]. However, the [_pArgument] is
  /// the term used in function call. The argument can be in the form of any expressions.
  Node _pArgument() {
    Node argument = this._pExpression();
    List<Node> arguments = [];
    if (argument != null) {
      arguments.add(argument);
      this._pArgumentPrime(arguments);
      return Arguments(arguments);
    }
    return null;
  }


  /// The [_pArgument] is ts the right recursion for [_pArgument]
  void _pArgumentPrime(List<Node> arguments) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.COMMA) {
      Node argument = this._pExpression();
      if (argument != null) {
        arguments.add(argument);
        this._pArgumentPrime(arguments);
      } else {
        Errors.addError(ParserError(this._tokens[this._index], (String t, int s, int e) => 'Expect argument after comma of index [${s}:${e}]!'));
      }
      return;
    } 
    --this._index;
    return;
  }


  /// The [_pIdentifier] is used to parse an identifier. It is mostly used in assignments, functions, and
  /// parameters. The identifers in arguments use the identifier parse from expression.
  Identifier _pIdentifier() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      return Identifier(
        token[1],
      );
    }
    --this._index;
    return null;
  }
}