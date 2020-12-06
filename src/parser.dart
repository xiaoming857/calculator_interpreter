import 'lexer.dart';

class Parser {
  List<Map<TOKEN_TYPE, String>> _tokens;
  int _index;

  Parser._internal();
  static final Parser _instance = Parser._internal();

  factory Parser() {
    return _instance;
  }

  bool parse(List<Map<TOKEN_TYPE, String>> tokens) {
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

  bool _pStart() {
    return this._pExpression() && this._expect(TOKEN_TYPE.EOF);
  }


  bool _pExpression() {
    return this._pTerm() && this._pExpressionPrime();
  }

  bool _pExpressionPrime() {
    ++this._index;
    if (this._tokens[this._index].containsKey(TOKEN_TYPE.ADD) || this._tokens[this._index].containsKey(TOKEN_TYPE.SUBTRACT)) {
      return this._pTerm() && this._pExpressionPrime();
    }

    --this._index;
    return true;
  }


  bool _pTerm() {
    return this._pFactor() && this._pTermPrime();
  }


  bool _pTermPrime() {
    ++this._index;
    if (this._tokens[this._index].containsKey(TOKEN_TYPE.MULTIPLY) || this._tokens[this._index].containsKey(TOKEN_TYPE.DIVIDE)) {
      return this._pFactor() && this._pTermPrime();
    }

    --this._index;
    return true;
  }


  bool _pFactor() {
    ++this._index;
    if (this._tokens[this._index].containsKey(TOKEN_TYPE.SUBTRACT)) {
      return _pFactor();
    } else if (this._tokens[this._index].containsKey(TOKEN_TYPE.NUMBER)) {
      return true;
    } else if (this._tokens[this._index].containsKey(TOKEN_TYPE.OPEN_PARENTHESIS)) {
      return this._pExpression() && this._expect(TOKEN_TYPE.CLOSE_PARENTHESIS);
    }

    print('${(this._tokens[this._index].containsKey(TOKEN_TYPE.EOF)) ? this._tokens[this._index - 1] : this._tokens[this._index]} is wrong!');
    --this._index;
    return false;
  }
}