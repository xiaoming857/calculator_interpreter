enum TOKEN_TYPE {
  EOF,
  NUMBER,
  ADD, SUBTRACT, MULTIPLY, DIVIDE, POWER, MOD,
  OPEN_PARENTHESIS, CLOSE_PARENTHESIS,
}

class Lexer {
  static final operators = ['+', '-', '*', '/', '^', '%']; // List of operators (that separates operands)
  static bool isDigit(String value) => RegExp(r'^\d$').hasMatch(value);
  static bool isNumber(String value) => RegExp(r'^(0$|[1-9]+)\d*$|^\d+\.\d+$').hasMatch(value);

  // Get tokens from a string of arithmetic expression
  static List<List<dynamic>> getTokens(String str) {
    List<List<dynamic>> tokens = List<List<dynamic>>();

    int i = 0; // Index
    while (i < str.length) {
      switch (str[i]) {
        case ' ': break;
        case '+': tokens.add([TOKEN_TYPE.ADD, '+', [i, i]]); break;
        case '-': tokens.add([TOKEN_TYPE.SUBTRACT, '-', [i, i]]); break;
        case '*': tokens.add([TOKEN_TYPE.MULTIPLY, '*', [i, i]]); break;
        case '/': tokens.add([TOKEN_TYPE.DIVIDE, '/', [i, i]]); break;
        case '^': tokens.add([TOKEN_TYPE.POWER, '^', [i, i]]); break;
        case '%': tokens.add([TOKEN_TYPE.MOD, '%', [i, i]]); break;
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

            temp = temp.trimRight(); // Removes succeeding spaces
            int iEnd = iStart + temp.length - 1; // End index

            if (isNumber(temp)) tokens.add([TOKEN_TYPE.NUMBER, temp, [iStart, iEnd]]); // Valid number
            else throw Exception('Invalid number ($temp) at index [$iStart, $iEnd]'); // Invalid number

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