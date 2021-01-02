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
    throw Exception('Unexpected token ${this._tokens[this._index]}! it is expceted to have token [$_token]!');
  }


  bool _peek(TOKEN_TYPE token, [step = 1]) {
    return (this._tokens[this._index + step][0] == token);
  }


  Node _pStart() {
    if (_peek(TOKEN_TYPE.EOF)) return null;
    Node result = this._pStatement();
    if (result == null) result = this._pDeclaration();
    if (result == null) result = this._pExpression();
    if (this._expect(TOKEN_TYPE.EOF)) return result;
    return null;
  }


  Node _pDeclaration() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.FUNCTION) {
      Identifier identifier = this._pIdentifier();
      if (identifier == null) throw Exception('Expect function name!');
      if (_expect(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        if (_peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) throw Exception('A function is expected to have at least one parameter!');
        Parameters parameters = this._pParameter();
        if (parameters == null) throw Exception('Expecet a parameter!');

        if (_expect(TOKEN_TYPE.CLOSE_PARENTHESIS) && _expect(TOKEN_TYPE.ARROW)) {
          try {
            Node expression = this._pExpression();
            if (expression != null) {
              return Function(
                identifier,
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
    --this._index;
    return null;
  }


  Node _pStatement() {
    ++this._index;
    List<dynamic> token = this._tokens[this._index];
    if (token[0] == TOKEN_TYPE.IDENTIFIER && _peek(TOKEN_TYPE.EQUAL)) {
      ++this._index;
      if (_peek(TOKEN_TYPE.EOF)) throw Exception('Expected an expression after ${this._tokens[this._index]}!');
      Node expression = this._pExpression();
      return Assignment(
        Identifier(token[1]),
        expression,
      );
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
      return (!(_peek(TOKEN_TYPE.IDENTIFIER) || _peek(TOKEN_TYPE.NUMBER))) ? Number(double.parse(_tokens[this._index][1])) : throw Exception('Excpect an operator after an operand ${this._tokens[this._index]}!');
    } else if (token[0] == TOKEN_TYPE.OPEN_PARENTHESIS) {
      Node rCalc = this._pExpression();
      if (this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS)) return rCalc;
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      Node rCalc = Identifier(token[1]);
      if (this._peek(TOKEN_TYPE.OPEN_PARENTHESIS)) {
        ++this._index;
        if (this._peek(TOKEN_TYPE.CLOSE_PARENTHESIS)) throw Exception('A function call is expected to have at least 1 argument!');
        rCalc = FunctionCall(
          rCalc,
          this._pArgument(),
        );
        _expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
      }
      if (_peek(TOKEN_TYPE.IDENTIFIER) || _peek(TOKEN_TYPE.NUMBER)) throw Exception('Excpect an operator after an operand!');
      return rCalc;
    }

    if (this._index <= 0) {
      Node lookAhead;
      try {
        lookAhead = _pFactor();
      } catch (e) {}

      if (lookAhead != null) throw Exception('Unexpected token ${this._tokens[this._index]} without preceeded by any operand!');
      throw Exception('Unexpected token ${this._tokens[this._index]} without preceeded and succeeded by any operand!');
    } else {
      throw Exception('Unexpected token ${this._tokens[this._index]} after token ${this._tokens[this._index - 1]}! It is expected to be an operand!');
    }
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
        this._pParameterPrime(parameters);
        return;
      }
      throw Exception('Expect parameter after comma (,)!');
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER) {
      throw Exception('Expect a comma (,) after an argument!');
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
        return;
      }
      throw Exception('Expect argument after comma (,)!');
    } else if (token[0] == TOKEN_TYPE.IDENTIFIER || token[0] == TOKEN_TYPE.NUMBER) {
      throw Exception('Expect a comma (,) after an argument!');
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