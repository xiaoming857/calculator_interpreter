import 'lexer.dart';
import 'ast.dart';

class Parser {
  String _code;
  List<List<dynamic>> _tokens;
  List<Error> _errors;
  int _index;


  Parser._internal();
  static final Parser _instance = Parser._internal();



  factory Parser() {
    return _instance;
  }


  AST parse(List<List<dynamic>> tokens, String code) {
    this._code = code;
    this._tokens = tokens;
    this._errors = [];
    this._index = -1;
    return AST(this._pStart());
  }
  

  void _mustBe(List<TOKEN_TYPE> tokenTypes) {
    List<dynamic>token = this._tokens[this._index];
    while (!tokenTypes.contains(token[0]) && token[0] != TOKEN_TYPE.EOF) {
      this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Unexpected ${t} at index [${s}:${e}]!'));
      token = this._tokens[++this._index];
    }
    --this._index;
  }


  Node _expect(TOKEN_TYPE tokenType) {
    List<dynamic> token = this._tokens[this._index + 1];
    if (token[0] == tokenType) return null;
    Error error = Error(this._code, token, (String t, int s, int e) => 'Unexpected ${t} at index [${s}:${e}]! it is expected to have token [$tokenType]!');
    this._errors.add(error);
    return error;
  }


  bool _peek(TOKEN_TYPE token, [step = 1]) {
    return (this._tokens[this._index + step][0] == token);
  }


  Node _pStart() {
    if (this._peek(TOKEN_TYPE.EOF)) return null;
    Node tree = this._pDeclaration();
    if (tree == null && this._errors.length == 0) tree = this._pStatement();
    if (tree == null && this._errors.length == 0) tree = this._pExpression();
    this._expect(TOKEN_TYPE.EOF);
    print(this._index);
    if (this._errors.length > 0) {
      this._errors.forEach((element) {
        print(element);
      });

      return null;
    }
    
    return tree;
  }


  Node _pDeclaration() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.FUNCTION) {
      Identifier identifier = this._pIdentifier();
      if (identifier == null) {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected a function name after ${t} of index [${s}:${e}]!'));
      } else {
        token = this._tokens[this._index];
      }

      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        token = this._tokens[++this._index];
        if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
          
        }
      } else {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected an open parenthesis after ${t} of index [${s}:${e}]!'));
      }

      Parameters parameters = this._pParameter();
      if (parameters == null) {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected a parameter after ${t} of index [${s}:${e}]!'));
      } else {
        token = this._tokens[this._index];
      }

      if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
        token = this._tokens[++this._index];
      } else {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected a close parenthesis after ${t} of index [${s}:${e}]!'));
      }

      if (this._peek(TOKEN_TYPE.ARROW)) {
        token = this._tokens[++this._index];
      } else {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected an arrow after ${t} of index [${s}:${e}]!'));
      }


      Node expression = this._pExpression();
      if (expression != null) {
        return Function(
          identifier,
          parameters,
          expression,
        );
      } else {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected an expression after ${t} of index [${s}:${e}]!'));
      }
      return null;
    }
    --this._index;
    return null;
  }

  
  Node _pStatement() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.IDENTIFIER && this._peek(TOKEN_TYPE.EQUAL)) {
      ++this._index;
      if (this._peek(TOKEN_TYPE.EOF)) {
        this._errors.add(Error(this._code, this._tokens[this._index], (String t, int s, int e) => 'Expected an expression after ${t} of index [${s}:${e}]'));
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


  Node _pTerm() {
    Node lVal = this._pPower();
    if (lVal != null) {
      Node rCalc = this._pTermPrime(lVal);
      if (rCalc != null) return rCalc;
      return lVal;
    }
    return null;
  }


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

  
  Node _pPower() {
    Node lVal = this._pFactor();
    if (lVal != null) {
      Node rCalc = this._pPowerPrime(lVal);
      if (rCalc != null) return rCalc;
      return lVal;
    }
    return null;
  }


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
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
        ++this._index;
        return null;
      }
      Node rCalc = this._pExpression();
      if (rCalc != null) {
        if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS) == null) {
          ++this._index;
          return rCalc;
        }
      } else {
        this._errors.add(Error(this._code, token, (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
        this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
      }
      return null;
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      Node rCalc = Identifier(token[1]);
      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        ++this._index;
        if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) {
          this._errors.add(Error(this._code, this._tokens[this._index], (String t, int s, int e) => 'Expected an argument after token $t of index [${s}:${e}]!'));
          ++this._index;
          return null;
        }
        Node arguments = this._pArgument();
        if (arguments != null) {
          if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS) == null) {
            ++this._index;
            rCalc = FunctionCall(rCalc, arguments);
          }
        } else {
          this._errors.add(Error(this._code, this._tokens[this._index], (String t, int s, int e) => 'Expected an operand after token $t of index [${s}:${e}]!'));
          this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
        }
      }
      return rCalc;
    }

    this._mustBe([TOKEN_TYPE.NUMBER, TOKEN_TYPE.IDENTIFIER, TOKEN_TYPE.OPEN_PARENTHESIS, TOKEN_TYPE.MINUS]);
    if (!this._peek(TOKEN_TYPE.EOF)) {
      return this._pExpression();
    } 
    this._errors.add(Error(this._code, this._tokens[this._index + 1], (String t, int s, int e) => 'Unexpected $t at index [${s}:${e}]!'));
    return null;    
  }


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


  void _pParameterPrime(List<Identifier> parameters) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.COMMA) {
      Node parameter = this._pIdentifier();
      if (parameter != null) {
        parameters.add(parameter);
        this._pArgumentPrime(parameters);
      } else {
        this._errors.add(Error(this._code, this._tokens[this._index], (String t, int s, int e) => 'Expect argument after comma of index [${s}:${e}]!'));
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


  void _pArgumentPrime(List<Node> arguments) {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.COMMA) {
      Node argument = this._pExpression();
      if (argument != null) {
        arguments.add(argument);
        this._pArgumentPrime(arguments);
      } else {
        this._errors.add(Error(this._code, this._tokens[this._index], (String t, int s, int e) => 'Expect argument after comma of index [${s}:${e}]!'));
      }
      return;
    } 
    --this._index;
    return;
  }


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