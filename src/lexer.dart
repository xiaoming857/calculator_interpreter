import 'errors.dart';


/// Token types
/// - EOF is [$] symbol which marks the end of a string
/// - IDENTIFIER follows the rules of variable naming
/// - NUMBER is both whole and decimal numbers
/// - FUNCTION is [func], a reserved word to mark function declaration
/// - ARROW is [->], separator between function header and function body
/// - COMMA is [,], separator between arguments or parameters
/// - EQUAL is [=], used in variable assignment
/// - PLUS is [+], used in addition operations
/// - MINUS is [-], used in subtraction operations and marks negative numbers
/// - ASTERISK is [*], used in multiplication operations
/// - SLASH is [/], used in division operations
/// - PERCENT is [%], used in modulo operations
/// - CARET is [^], used in exponential operations
/// - OPEN_PARENTHESIS is [(] and CLOSE_PARENTHESIS is [)], used in adjustment of precedence of operations
enum TOKEN_TYPE {
  EOF,
  IDENTIFIER,
  NUMBER,
  FUNCTION,
  ARROW,
  COMMA,
  EQUAL, PLUS, MINUS, ASTERISK, SLASH, PERCENT, CARET,
  OPEN_PARENTHESIS, CLOSE_PARENTHESIS,
}


/// The Lexer class is used for lexicial analysis, one of the stage in an interpreter.
/// It receives a string input and generates a list of tokens which will be used in parser. 
class Lexer {
  /// Determine a valid digit by using regex
  static bool isDigit(String value) => RegExp(r'^\d$').hasMatch(value);

  /// Determine a valid number by using regex
  static bool isNumber(String value) => RegExp(r'^(0$|[1-9]+)\d*$|^\d+\.\d+$').hasMatch(value);

  /// Determine a valid alphabetical character by using regex
  static bool isLetter(String value) => RegExp(r'^[a-zA-Z]$').hasMatch(value);

  /// Determine a valid identifier by using regex. It follows the rules of
  ///     a variable naming:
  ///     - Contains any aphabet, either lowered or uppercased
  ///     - Can contains underscore at any position and even stand alone.
  ///     - Can contains number, however only after preceeded by alphabets or underscores
  static bool isIdentifier(String value) => RegExp(r'^[a-zA-Z_]+[a-zA-Z\d_]*$').hasMatch(value);

  // Stores valid tokens
  final List<List<dynamic>> _tokens = List<List<dynamic>>();


  /// Get tokens from a string of arithmetic expression. Accepts a string input and returns a list of tokens
  /// A token is a list that consists of 3 items:
  /// - index 0: token type or [TOKEN_TYPE] enum,
  /// - index 1: the string representation,
  /// - index 2: the position of the string which is a list of 2 items: a start and an end index.
  /// 
  /// In case of the detection of an invalid character, it will add the error to the [Errors] class and continue
  /// with the lexing until it reaches the end of the input string. Finally returning the list of tokens without
  /// the existence of the invalid character (skipped).
  /// 
  /// If spaces exist between identifiers, it will be considered as 2 tokens. On the other hand, it will be considered
  /// as invalid in case of numbers.
  List<List<dynamic>> getTokens(String str) {
    int i = 0; // Index
    while (i < str.length) {
      switch (str[i]) {
        case ' ': break;
        case '=': this._tokens.add([TOKEN_TYPE.EQUAL, '=', [i, i]]); break;
        case '+': this._tokens.add([TOKEN_TYPE.PLUS, '+', [i, i]]); break;
        case '-': {
          if (i + 1 < str.length && str[i + 1] == '>') {
            this._tokens.add([TOKEN_TYPE.ARROW, '->', [i, i + 1]]);
            ++i;
          } else {
            this._tokens.add([TOKEN_TYPE.MINUS, '-', [i, i]]);
          }
        } break;
        case '*': this._tokens.add([TOKEN_TYPE.ASTERISK, '*', [i, i]]); break;
        case '/': this._tokens.add([TOKEN_TYPE.SLASH, '/', [i, i]]); break;
        case '^': this._tokens.add([TOKEN_TYPE.CARET, '^', [i, i]]); break;
        case '%': this._tokens.add([TOKEN_TYPE.PERCENT, '%', [i, i]]); break;
        case '(': this._tokens.add([TOKEN_TYPE.OPEN_PARENTHESIS, '(', [i, i]]); break;
        case ')': this._tokens.add([TOKEN_TYPE.CLOSE_PARENTHESIS,')', [i, i]]); break;
        case ',': this._tokens.add([TOKEN_TYPE.COMMA, ',', [i, i]]); break;
        default: {
          String temp = '';
          int iStart = i; // Start index
          if (isDigit(str[i])) {
            // Validate digit
            while (i < str.length && (isDigit(str[i]) || str[i] == '.' || str[i] == ' ')) {
              temp += str[i];
              i++;
            }

            temp = temp.trimRight(); // Remove succeeding spaces
            int iEnd = iStart + temp.length - 1; // End index
            if (isNumber(temp)) this._tokens.add([TOKEN_TYPE.NUMBER, temp, [iStart, iEnd]]); // Valid number
            else Errors.addError(LexerError([iStart, iEnd], (String str, int s, int e) => 'Invalid number (contains spaces) at index [${s}:${e}]!'));

            continue;

          } else if (isLetter(str[i]) || str[i] == '_') {
            // Validate identifier
            while (i < str.length && (isLetter(str[i]) || isNumber(str[i]) || str[i] == '_')) {
              temp += str[i];
              i++;
            }

            temp = temp.trimRight(); // Remove succeeding spaces
            int iEnd = iStart + temp.length - 1; // End index

            if (isIdentifier(temp)) {
              // Valid identifier
              switch (temp) {
                case 'func': this._tokens.add([TOKEN_TYPE.FUNCTION, temp, [iStart, iEnd]]); break; // Reserved word func
                default: this._tokens.add([TOKEN_TYPE.IDENTIFIER, temp, [iStart, iEnd]]);
              }
            }
            else Errors.addError(LexerError([iStart, iEnd], (String str, int s, int e) => 'Invalid identifier ${str} at index [${s}:${e}]!'));
            
            continue;
            
          } else {
            Errors.addError(LexerError([i, i], (String str, int s, int e) => 'Invalid character ${str} at index [${s}:${e}]!'));
          }
        }
      }
      i++;
    }
    this._tokens.add([TOKEN_TYPE.EOF, '\$', [i, i]]); // Marks ending
    return this._tokens;
  } 
}