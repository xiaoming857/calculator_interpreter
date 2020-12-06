enum TOKENS {
  ASSIGN,
  ADD,
  SUBTRACT,
  MULTIPLY,
  DIVIDE,
  POWER,
  OPEN_PARENTHESIS,
  CLOSE_PARENTHESIS,
  PERCENT,
  FACTORIAL,
  SEPARATOR,
  MOD,
  SIN,
  COSEC,
  COS,
  SEC,
  TAN,
  COTAN,
  LOG,
  LN,
  AVG,
  ABS,
  FLOOR,
  CEIL,
  ROUND,
  NUMBER,
  PI,
  E,
  IDENTIFIER,
}

RegExp isDigit = RegExp(r'^\d$');
RegExp isNum = RegExp(r'^\d$|^\d+\.?\d+$');
RegExp isLetter = RegExp(r'^[a-zA-Z]$');
RegExp isIdentifier = RegExp('^${isLetter}+(\\d|${isLetter})*\$');

// Operators
Map<String, TOKENS> operators = {
  '=': TOKENS.ASSIGN,
  '+': TOKENS.ADD,
  '-': TOKENS.SUBTRACT,
  '*': TOKENS.MULTIPLY,
  '/': TOKENS.DIVIDE,
  '^': TOKENS.POWER,
  '(': TOKENS.OPEN_PARENTHESIS,
  ')': TOKENS.CLOSE_PARENTHESIS,
  '%': TOKENS.PERCENT,
  '!': TOKENS.FACTORIAL,
  ',': TOKENS.SEPARATOR,
};

// Operations
Map<String, TOKENS> operations = {
  'mod': TOKENS.MOD,
  'sin': TOKENS.SIN,
  'csc': TOKENS.COSEC,
  'cos': TOKENS.COS,
  'sec': TOKENS.SEC,
  'tan': TOKENS.TAN,
  'cot': TOKENS.COTAN,
  'log': TOKENS.LOG,
  'ln': TOKENS.LN,
  'avg': TOKENS.AVG,
  'abs': TOKENS.ABS,
  'flr': TOKENS.FLOOR,
  'ceil': TOKENS.CEIL,
  'round': TOKENS.ROUND,
};

// Constants
Map<String, TOKENS> constants = {
  'pi': TOKENS.PI,
  'e': TOKENS.E,
};

/// Tokenization
List getToken(String str) {
  List<TOKENS> tokens = [];

  str = str.replaceAll(' ', ''); // Removes spaces
  int i = 0; // Index
  while (i < str.length) {
    if (operators.containsKey(str[i])) {
      // Operators
      tokens.add(operators[str[i]]);
      i++;
    } else {
      // Operands
      String temp = '';
      if (isDigit.hasMatch(str[i])) {
        // Numbers
        while (i < str.length && (isDigit.hasMatch(str[i]) || str[i] == '.')) {
          temp += str[i];
          i++;
        }

        if (isNum.hasMatch(temp)) {
          tokens.add(TOKENS.NUMBER);
        } else {
          throw Exception('INVALID NUMBER(${temp})');
        }
      } else if(isLetter.hasMatch(str[i])) {
        // Keywords
        while (i < str.length && (isLetter.hasMatch(str[i]) || isDigit.hasMatch(str[i]))) {
          temp += str[i];
          i++;
        }

        if (operations.containsKey(temp)) {
          // Reserved keywords (functions)
          tokens.add(operations[temp]);
        } else if (constants.containsKey(temp)) {
          // Reserved keywords (constants)
          tokens.add(constants[temp]);
        } else {
          // Unreserved keywords (identifiers)
          tokens.add(TOKENS.IDENTIFIER);
        }
      } else {
        // Invalid characters
        throw Exception('INVALID CHARACTER(${str[i]}) FOUND AT POSITION(${i})');
      }
    }
  }

  return tokens;
}