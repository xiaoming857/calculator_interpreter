import 'lexer.dart';

class Parser {
  List<Map<TOKEN_TYPE, String>> _tokens;
  int _index;

  Parser._internal();
  static final Parser _instance = Parser._internal();

  factory Parser() {
    return _instance;
  }

  double parse(List<Map<TOKEN_TYPE, String>> tokens) {
    this._tokens = tokens;
    _instance._index = -1;
    return this._pStart();
  }
  

  bool _expect(TOKEN_TYPE _token) {
    ++this._index;
    if (this._tokens[this._index].containsKey(_token)) {
      return true;
    }

    --this._index;
    return false;
  }

  double _pStart() {
    double result = this._pExpression();
    if (this._expect(TOKEN_TYPE.EOF)) return result;

    return null;
  }


  double _pExpression() {
    double lNum = this._pTerm();
    if (lNum != null) {
      List<dynamic> rCalc = this._pExpressionPrime();
      if (rCalc != null) {
        if (rCalc[0] == TOKEN_TYPE.ADD) {
          return lNum + rCalc[1];
        } else if (rCalc[0] == TOKEN_TYPE.SUBTRACT) {
          return lNum - rCalc[1];
        }
      }

      return lNum;
    }

    return null;
  }


  List<dynamic> _pExpressionPrime() {
    ++this._index;

    TOKEN_TYPE token = this._tokens[this._index].keys.first;
    if (token == TOKEN_TYPE.ADD || token == TOKEN_TYPE.SUBTRACT) {
      double lNum = this._pTerm();
      List<dynamic> rCalc = this._pExpressionPrime();
      
      if (lNum != null) {
        if (rCalc != null) {
          if (rCalc[0] == TOKEN_TYPE.ADD) {
            lNum = lNum + rCalc[1];
          } else if (rCalc[0] == TOKEN_TYPE.SUBTRACT) {
            lNum = lNum - rCalc[1];
          } 
        }

        return [token, lNum];
      }
    }

    --this._index;
    return null;
  }


  double _pTerm() {
    double lNum = this._pFactor();
    if (lNum != null) {
      List<dynamic> rCalc = this._pTermPrime();
      if (rCalc != null) {
        if (rCalc[0] == TOKEN_TYPE.MULTIPLY) {
          return lNum * rCalc[1];
        } else if (rCalc[0] == TOKEN_TYPE.DIVIDE) {
          return lNum / rCalc[1];
        }
      }

      return lNum;
    }

    return null;
  }


  List<dynamic> _pTermPrime() {
    ++this._index;

    TOKEN_TYPE token = this._tokens[this._index].keys.first;
    if (token == TOKEN_TYPE.MULTIPLY || token == TOKEN_TYPE.DIVIDE) {
      double lNum = this._pFactor();
      List<dynamic >rCalc = this._pTermPrime();
      
      if (lNum != null) {
        if (rCalc != null) {
          if (rCalc[0] == TOKEN_TYPE.MULTIPLY) {
            lNum = lNum * rCalc[1];
          } else if (rCalc[0] == TOKEN_TYPE.DIVIDE) {
            lNum = lNum / rCalc[1];
          }
        }

        return [token, lNum];
      }
    }

    --this._index;
    return null;
  }


  double _pFactor() {
    ++this._index;
    if (this._tokens[this._index].containsKey(TOKEN_TYPE.SUBTRACT)) {
      return -_pFactor();
    } else if (this._tokens[this._index].containsKey(TOKEN_TYPE.NUMBER)) {
      return double.parse(_tokens[this._index][TOKEN_TYPE.NUMBER]);
    } else if (this._tokens[this._index].containsKey(TOKEN_TYPE.OPEN_PARENTHESIS)) {
      double tempNum = this._pExpression();
      if (tempNum != null && this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS)) return tempNum;
    }

    print('${(this._tokens[this._index].containsKey(TOKEN_TYPE.EOF)) ? this._tokens[this._index - 1] : this._tokens[this._index]} is wrong!');
    --this._index;
    return null;
  }
}