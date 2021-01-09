import 'ast.dart';


/// The [Errors] class is used to contain errors from lexer, parser, and interpreter.
class Errors {
  /// Stores errors
  static final List<InterpreterError> _errors = [];
  
  /// Getter for errors, returns a new list to avoid leakage.
  static List<InterpreterError> get errors => _errors.toList();


  /// Check if an error exists in [_errors] list.
  static bool hasError() {
    return _errors.length != 0;
  }


  /// Check if errors with a type that extends [InterpreterError] exists in
  /// [_errors] list.
  static hasType<T extends InterpreterError>() {
    return _errors.whereType<T>().length != 0;
  }


  /// Add an error to [_errors] list.
  static void addError(InterpreterError error) {
    _errors.add(error);
  }


  /// Clear all errors from [_errors] list.
  static clear() {
    _errors.clear();
  }


  /// Print all errors in [_errors] list.
  static printErrors() {
    if (hasError()) {
      _errors.forEach((e) {
        print(e);
      });
    }
  }
}


/// The [InterpreterError] is the parent class of all errors in the interpreter.
class InterpreterError {
  /// The input string, used in for visualization
  static String code;

  /// The message for the error
  String _message;

  /// The visualzation of the error
  String _visual;

  /// Getters
  String get message => this._message;
  String get visual => this._visual;


  /// The toString method returns a complete error message by combining [_message] and [_visualize]. It
  /// will only print out [_message] if the [_visualize] is null.
  @override
  String toString() {
    return '\nError: ${this._message}\n${(this.visual == null) ? '' : this._visual + '\n'}';
  }
}


/// The [LexerError] extends [InterpreterError] with some additional methods. It is used for any errors
/// occured in lexical analysis (lexer process).
class LexerError extends InterpreterError {
  /// The position of the error within the input string, used in visualization
  final List<int> _index;
  
  /// The error character or string
  String _str;

  /// Getters
  String get str => this._str;
  List<dynamic> get index => this._index.toList();


  /// Constructor for the class, generates the [_message] and [_visual].
  LexerError(this._index, String Function(String str, int startIndex, int endIndex) message) {
    this._str = InterpreterError.code.substring(this._index[0], this._index[1] + 1);
    super._message = message(this._str, this._index[0], this.index[1]);
    super._visual = this._getVisual(InterpreterError.code, this._index[0], this._index[1]);
  }


  /// Generator for the visualization. Accepts 4 parameters:
  /// - code, the string input
  /// - startIndex, the beginning index of the error string
  /// - endIndex, the end index of the error string
  /// - spacing, the number of spaces preceeding the visualization, by default is 3
  String _getVisual(String code, int startIndex, int endIndex, {int spacing = 3}) {
    // Check for invalid input parameters
    if (code == null || code.isEmpty || startIndex == null || endIndex == null || (spacing == null && spacing < 0) || !(startIndex >= 0 && startIndex <= code.length) || !(endIndex >= startIndex && endIndex <= code.length)) {
      return null;
    }
    
    /// Generates the pointer to point out the error string in the input string.
    /// It will only have a pointer in case the cause of the error is only 1 character, e.g.
    /// 
    /// 1 ++ 1
    ///    ^
    /// 
    /// Otherwise it will have a wider pointer, e.g.
    /// 
    /// func func add(a, b) -> a + b
    ///      ^--^ 
    String pointer = (startIndex == endIndex)
      ? '${' ' * (startIndex)}^'
      : '${' ' * (startIndex)}^${'-' * (endIndex - startIndex - 1)}^';

    return '${' ' * spacing}${InterpreterError.code}\n${' ' * spacing}${pointer}';
  }
}


/// The [ParserError] extends [InterpreterError] with some additional methods. It is used for any errors
/// occured in syntax analysis (parser process).
class ParserError extends InterpreterError {
  /// The token that causes the the error
  final List<dynamic> _token;

  /// Getter
  List<dynamic> get token => _token.toList();

  /// Constructor of the class, generates the [_message] and [_visual].
  ParserError(this._token, String Function(String token, int startIndex, int endIndex) message) {
    super._message = message(this._token[0].toString(), this._token[2][0], this._token[2][1]);
    super._visual = this._getVisual(InterpreterError.code, this._token[2][0], this._token[2][1]);
  }


  /// Generator for the visualization. Accepts 4 parameters:
  /// - code, the string input
  /// - startIndex, the beginning index of the error string
  /// - endIndex, the end index of the error string
  /// - spacing, the number of spaces preceeding the visualization, by default is 3
  String _getVisual(String code, int startIndex, int endIndex, {int spacing = 3}) {
    // Check for invalid input parameters
    if (code == null || code.isEmpty || startIndex == null || endIndex == null || (spacing == null && spacing < 0) || !(startIndex >= 0 && startIndex <= code.length) || !(endIndex >= startIndex && endIndex <= code.length)) {
      return null;
    }
    
    /// Generates the pointer to point out the error string in the input string.
    /// It will only have a pointer in case the cause of the error is only 1 character, e.g.
    /// 
    /// 1 ++ 1
    ///    ^
    /// 
    /// Otherwise it will have a wider pointer, e.g.
    /// 
    /// func func add(a, b) -> a + b
    ///      ^--^ 
    String pointer = (startIndex == endIndex)
      ? '${' ' * (startIndex)}^'
      : '${' ' * (startIndex)}^${'-' * (endIndex - startIndex - 1)}^';

    return '${' ' * spacing}${InterpreterError.code}\n${' ' * spacing}${pointer}';
  }
}


/// The [SemanticAnalyzerError] extends [InterpreterError] with some additional methods. It is used for any errors
/// occured in semantic analyis (semantic analyzer phase)
class SemanticAnalyzerError<T extends Node> extends InterpreterError {
  /// The node that contains the root of error
  final T _node;

  /// Constructor 
  SemanticAnalyzerError(this._node, String Function(T node) message) {
    super._message = message(this._node);
    super._visual = this._getVisual(this._node);
  }


  /// Generator for the visualization. Accepts 2 parameters:
  /// - node, the that contains the error
  /// - spacing, the number of spaces preceeding the visualization, by default is 3
  String _getVisual(T node, {int spacing = 3}) {
    // Check for invalid input parameters
    if (node == null || (spacing == null && spacing < 0)) {
      return null;
    }

    return '${' ' * spacing}${node.toString()}';
  }
}