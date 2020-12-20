enum TOKEN_TYPE {
  EOF,
  IDENTIFIER, RESERVED_KEYWORD,
  NUMBER,
  EQUAL, PLUS, MINUS, ASTERISK, SLASH, CARET, PERCENT,
  OPEN_PARENTHESIS, CLOSE_PARENTHESIS,
}

class Lexer {
  static final List<String> operators = ['=', '+', '-', '*', '/', '^', '%']; // List of operators (that separates operands)
  static final List<String> reservedKeywords = ['var'];
  static bool isDigit(String value) => RegExp(r'^\d$').hasMatch(value);
  static bool isNumber(String value) => RegExp(r'^(0$|[1-9]+)\d*$|^\d+\.\d+$').hasMatch(value);
  static bool isLetter(String value) => RegExp(r'^[a-zA-Z]$').hasMatch(value);
  static bool isIdentifier(String value) => RegExp(r'^[a-zA-Z_]+[a-zA-Z\d_]*$').hasMatch(value);

  // Get tokens from a string of arithmetic expression
  static List<List<dynamic>> getTokens(String str) {
    List<List<dynamic>> tokens = List<List<dynamic>>();

    int i = 0; // Index
    while (i < str.length) {
      switch (str[i]) {
        case ' ': break;
        case '=': tokens.add([TOKEN_TYPE.EQUAL, '=', [i, i]]); break;
        case '+': tokens.add([TOKEN_TYPE.PLUS, '+', [i, i]]); break;
        case '-': tokens.add([TOKEN_TYPE.MINUS, '-', [i, i]]); break;
        case '*': tokens.add([TOKEN_TYPE.ASTERISK, '*', [i, i]]); break;
        case '/': tokens.add([TOKEN_TYPE.SLASH, '/', [i, i]]); break;
        case '^': tokens.add([TOKEN_TYPE.CARET, '^', [i, i]]); break;
        case '%': tokens.add([TOKEN_TYPE.PERCENT, '%', [i, i]]); break;
        case '(': tokens.add([TOKEN_TYPE.OPEN_PARENTHESIS, '(', [i, i]]); break;
        case ')': tokens.add([TOKEN_TYPE.CLOSE_PARENTHESIS,')', [i, i]]); break;
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
            else throw Exception('Invalid number ($temp) at index [$iStart, $iEnd]'); // Invalid number

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
              if (reservedKeywords.contains(temp)) tokens.add([TOKEN_TYPE.RESERVED_KEYWORD, temp, [iStart, iEnd]]); // Valid identifier and is a reserved keyword
              else tokens.add([TOKEN_TYPE.IDENTIFIER, temp, [iStart, iEnd]]); // Valid identifier
            }
            else throw Exception('Invalid number ($temp) at index [$iStart, $iEnd]'); // Invalid identifier
            
            continue;
            
          } else {
            throw Exception('Invalid character (${str[i]}) at index (${i})!');
          }
        }
      }

      i++;
    }

    tokens.add([TOKEN_TYPE.EOF, '\$', [i, i]]); // Marks ending
    return tokens;
  } 
}