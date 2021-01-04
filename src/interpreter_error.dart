class InterpreterError {
  static String code;
  String _message;
  String _visual;


  String get message => this._message;
  String get visual => this._visual;


  @override
  String toString() {
    return '\nError: ${this._message}\n${(this.visual == null) ? '' : this._visual + '\n'}';
  }
}


class LexerError extends InterpreterError {
  final List<int> _index;
  String _str;
  String get str => this._str;
  List<dynamic> get index => this._index.toList();


  LexerError(this._index, String Function(String str, int startIndex, int endIndex) message) {
    this._str = InterpreterError.code.substring(this._index[0], this._index[1] + 1);
    super._message = message(this._str, this._index[0], this.index[1]);
    super._visual = this._getVisual(InterpreterError.code, this._index[0], this._index[1]);
  }


  String _getVisual(String code, int startIndex, int endIndex, {int spacing = 3}) {
    if (code == null || code.isEmpty || startIndex == null || endIndex == null || (spacing == null && spacing < 0) || !(startIndex >= 0 && startIndex <= code.length) || !(endIndex >= startIndex && endIndex <= code.length)) {
      return null;
    }
    
    String pointer = (startIndex == endIndex)
      ? '${' ' * (startIndex)}^'
      : '${' ' * (startIndex)}^${'-' * (endIndex - startIndex - 1)}^';

    return '${' ' * spacing}${InterpreterError.code}\n${' ' * spacing}${pointer}';
  }
}


class ParserError extends InterpreterError {
  final List<dynamic> _token;

  List<dynamic> get token => _token.toList();

  ParserError(this._token, String Function(String token, int startIndex, int endIndex) message) {
    this._message = message(this._token[0].toString(), this._token[2][0], this._token[2][1]);
    this._visual = this._getVisual(InterpreterError.code, this._token[2][0], this._token[2][1]);
  }


  String _getVisual(String code, int startIndex, int endIndex, {int spacing = 3}) {
    if (code == null || code.isEmpty || startIndex == null || endIndex == null || (spacing == null && spacing < 0) || !(startIndex >= 0 && startIndex <= code.length) || !(endIndex >= startIndex && endIndex <= code.length)) {
      return null;
    }
    
    String pointer = (startIndex == endIndex)
      ? '${' ' * (startIndex)}^'
      : '${' ' * (startIndex)}^${'-' * (endIndex - startIndex - 1)}^';

    return '${' ' * spacing}${InterpreterError.code}\n${' ' * spacing}${pointer}';
  }
}