enum TOKEN_TYPE {
  EOF,
  NUMBER,
  ADD, SUBTRACT, MULTIPLY, DIVIDE, POWER,
  OPEN_PARENTHESIS, CLOSE_PARENTHESIS
}

class Lexer {
  static bool isDigit(String value) => RegExp(r'[0-9]').hasMatch(value);
  static bool isLetter(String value) => RegExp(r'^[a-zA-Z]$').hasMatch(value);
  static bool isNumber(String value) => RegExp(r'^\d$|^\d+\.?\d+$').hasMatch(value);

  static final Map<String, TOKEN_TYPE> specialCharacters = {
    '+': TOKEN_TYPE.ADD,
    '-': TOKEN_TYPE.SUBTRACT,
    '*': TOKEN_TYPE.MULTIPLY,
    '/': TOKEN_TYPE.DIVIDE,
    '^': TOKEN_TYPE.POWER,
    '(': TOKEN_TYPE.OPEN_PARENTHESIS,
    ')': TOKEN_TYPE.CLOSE_PARENTHESIS
  };

  static final Map<String, TOKEN_TYPE> _functions = {
  };

  static List<Map<TOKEN_TYPE, String>> getTokens(String str) {
    List<Map<TOKEN_TYPE, String>> tokens = List<Map<TOKEN_TYPE,String>>();

    str = str.replaceAll(' ', ''); // Remove spaces
    int i = 0; // Index
    
    while (i < str.length) {
      if (specialCharacters.containsKey(str[i])) {
        tokens.add({specialCharacters[str[i]]: str[i]});
        i++;
      } else {
        String temp = '';
        if (isDigit(str[i]) || str[i] == '.') {
          while (i < str.length && (isDigit(str[i]) || str[i] == '.')) {
            temp += str[i];
            i++;
          }

          if (isNumber(temp)) {
            tokens.add({TOKEN_TYPE.NUMBER: temp});
          } else {
            throw Exception('INVALID NUMBER(${temp})');
          }
        } else if (isLetter(str[i])) {
          while (i < str.length && (isLetter(str[i]))) {
            temp += str[i];
            i++;
          }

          if (_functions.containsKey(temp)) {
            tokens.add({_functions[temp]: temp});
          } else {
            throw Exception('INVALID FUNCTION(${temp})');
          }
        } else {
          throw Exception('INVALID CHARACTER(${str[i]}) FOUND AT POSITION(${i})');
        }
      }
    }

    tokens.add({TOKEN_TYPE.EOF: '\$'});
    return tokens;
  } 
}