import 'interpreter_error.dart';


enum TOKEN_TYPE {
  EOF,
  IDENTIFIER,
  NUMBER,
  FUNCTION,
  ARROW,
  COMMA,
  EQUAL, PLUS, MINUS, ASTERISK, SLASH, CARET, PERCENT,
  OPEN_PARENTHESIS, CLOSE_PARENTHESIS,
}


class Lexer {   
  static bool isDigit(String value) => RegExp(r'^\d$').hasMatch(value);
  static bool isNumber(String value) => RegExp(r'^(0$|[1-9]+)\d*$|^\d+\.\d+$').hasMatch(value);
  static bool isLetter(String value) => RegExp(r'^[a-zA-Z]$').hasMatch(value);
  static bool isIdentifier(String value) => RegExp(r'^[a-zA-Z_]+[a-zA-Z\d_]*$').hasMatch(value);


  // Get tokens from a string of arithmetic expression
  static List<List<dynamic>> getTokens(String str) {
    final List<InterpreterError> errors = [];
    final List<List<dynamic>> tokens = List<List<dynamic>>();

    int i = 0; // Index
    while (i < str.length) {
      switch (str[i]) {
        case ' ': break;
        case '=': tokens.add([TOKEN_TYPE.EQUAL, '=', [i, i]]); break;
        case '+': tokens.add([TOKEN_TYPE.PLUS, '+', [i, i]]); break;
        case '-': {
          if (i + 1 < str.length && str[i + 1] == '>') {
            tokens.add([TOKEN_TYPE.ARROW, '->', [i, i + 1]]);
            ++i;
          } else {
            tokens.add([TOKEN_TYPE.MINUS, '-', [i, i]]);
          }
        } break;
        case '*': tokens.add([TOKEN_TYPE.ASTERISK, '*', [i, i]]); break;
        case '/': tokens.add([TOKEN_TYPE.SLASH, '/', [i, i]]); break;
        case '^': tokens.add([TOKEN_TYPE.CARET, '^', [i, i]]); break;
        case '%': tokens.add([TOKEN_TYPE.PERCENT, '%', [i, i]]); break;
        case '(': tokens.add([TOKEN_TYPE.OPEN_PARENTHESIS, '(', [i, i]]); break;
        case ')': tokens.add([TOKEN_TYPE.CLOSE_PARENTHESIS,')', [i, i]]); break;
        case ',': tokens.add([TOKEN_TYPE.COMMA, ',', [i, i]]); break;
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
            if (isNumber(temp)) tokens.add([TOKEN_TYPE.NUMBER, temp, [iStart, iEnd]]); // Valid number
            else errors.add(LexerError([iStart, iEnd], (String str, int s, int e) => 'Invalid number (contains spaces) at index [${s}:${e}]!'));

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
              switch (temp) {
                case 'func': tokens.add([TOKEN_TYPE.FUNCTION, temp, [iStart, iEnd]]); break;
                default: tokens.add([TOKEN_TYPE.IDENTIFIER, temp, [iStart, iEnd]]);
              }
            }
            else errors.add(LexerError([iStart, iEnd], (String str, int s, int e) => 'Invalid identifier ${str} at index [${s}:${e}]!'));
            
            continue;
            
          } else {
            errors.add(LexerError([i, i], (String str, int s, int e) => 'Invalid character ${str} at index [${s}:${e}]!'));
          }
        }
      }
      i++;
    }
    tokens.add([TOKEN_TYPE.EOF, '\$', [i, i]]); // Marks ending
    if (errors.length > 0) {
      errors.forEach((e) {
        print(e.toString());
      });
    }
    return tokens;
  } 
}