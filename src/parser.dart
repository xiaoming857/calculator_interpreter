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


  Node parse(List<List<dynamic>> tokens) {
    this._tokens = tokens;
    _instance._index = -1;
    return this._pStart();
  }
  

  bool _expect(TOKEN_TYPE _token) {
    ++this._index;
    if (this._tokens[this._index][0] == _token) return true;
    throw Exception('Unexpected token ${this._tokens[this._index]}, it is expceted to have token [$_token]');
  }


  Node _pStart() {
    Node result = this._pExpression();
    if (this._expect(TOKEN_TYPE.EOF)) return result;
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
    }

    throw Exception('${(this._tokens[this._index][0] == TOKEN_TYPE.EOF) ? this._tokens[this._index - 1] : this._tokens[this._index]} is wrong!');
  }
}