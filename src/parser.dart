import 'lexer.dart';
import 'ast.dart';

class Parser {
  List<List<dynamic>> _tokens;
  int _index;


  Parser._internal();
  static final Parser _instance = Parser._internal();


  factory Parser() {
    return _instance;
  }


  AST parse(List<List<dynamic>> tokens) {
    this._tokens = tokens;
    _instance._index = -1;
    return AST(this._pStart());
  }
  

  bool _expect(TOKEN_TYPE _token) {
    ++this._index;
    if (this._tokens[this._index][0] == _token) return true;
    throw Exception('Unexpected token ${this._tokens[this._index]}, it is expceted to have token [$_token]');
  }


  bool _peek(TOKEN_TYPE _token) {
    ++this._index;
    if (this._tokens[this._index][0] == _token) return true;
    --this._index;
    return false;
  }


  Node _pStart() {
    Node result = this._pStatement();
    if (result == null) result = this._pExpression();
    if (this._expect(TOKEN_TYPE.EOF)) return result;
    return null;
  }


  Node _pStatement() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      if (this._peek(TOKEN_TYPE.EQUAL)) {
        Node expression = this._pExpression();
        if (expression == null) throw Exception('Expect Expression!');
        return Assignment(
          Identifier(token[1]),
          expression,
        );
      }
    } else if (token[0] == TOKEN_TYPE.FUNCTION) {
      ++this._index;
      token = this._tokens[this._index];
      if (token[0] == TOKEN_TYPE.IDENTIFIER) {
        if (_expect(TOKEN_TYPE.OPEN_PARENTHESIS)) {
          Parameters parameters = this._pParameter();
          if (_expect(TOKEN_TYPE.CLOSE_PARENTHESIS) && _expect(TOKEN_TYPE.ARROW)) {
            try {
              Node expression = this._pExpression();
              if (expression != null) {
                return Function(
                  Identifier(token[1]),
                  parameters,
                  expression,
                );
              } 
            } catch (e) {
              throw Exception('Function expect expression body!');
            }
          }
        }
      }
      throw Exception('Expect function name!');
    }
    --this._index;
    return null;
  }


  Node _pExpression() {
    Node lVal = this._pTerm();
    if (lVal != null) {
      Node rCalc = this._pExpressionPrime(lVal);
      if (rCalc != null) return rCalc;
      return lVal;
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
      }
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
    }
    --this._index;
    return null;
  }


  Node _pFactor() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.MINUS) {
      return UnaryOperation(
        Operator(token[0], token[1]),
        _pFactor(),
      );
    } else if (token[0] == TOKEN_TYPE.NUMBER) {
      return Number(double.parse(_tokens[this._index][1]));
    } else if (token[0] == TOKEN_TYPE.OPEN_PARENTHESIS) {
      Node rCalc = this._pExpression();
      if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS)) return rCalc;
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      Node rCalc = Identifier(token[1]);
      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        rCalc = FunctionCall(
          rCalc,
          this._pArgument(),
        );
        _expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
      }
      return rCalc;
    }
    throw Exception('${(this._tokens[this._index][0] == TOKEN_TYPE.EOF) ? this._tokens[this._index - 1] : this._tokens[this._index]} is wrong!');
  }


  Node _pParameter() {
    Identifier parameter = this._pIdentifier();
    List<Identifier> parameters = [];
    if (parameter != null) {
      parameters.add(parameter);
      this._pParameterPrime(parameters);
      return Parameters(parameters);
    }
    if (parameters.isEmpty) throw Exception('Function expects at least 1 parameter!');
    throw Exception('Unexpected character ${this._tokens[this._index + 1]}');
  }


  void _pParameterPrime(List<Identifier> parameters) {
    ++this._index;
    if (this._tokens[this._index][0] == TOKEN_TYPE.COMMA) {
      Node parameter = this._pIdentifier();
      if (parameter != null) {
        parameters.add(parameter);
        this._pParameterPrime(parameters);
        return;
      }
      throw Exception('Expect parameter after comma (,)!');
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
    if (arguments.isEmpty) throw Exception('Function expects at least 1 argument!');
    throw Exception('Unexpected character ${this._tokens[this._index + 1]}');
  }


  void _pArgumentPrime(List<Node> arguments) {
    ++this._index;
    if (this._tokens[this._index][0] == TOKEN_TYPE.COMMA) {
      Node argument = this._pExpression();
      if (argument != null) {
        arguments.add(argument);
        this._pArgumentPrime(arguments);
        return;
      }
      throw Exception('Expect argument after comma (,)!');
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