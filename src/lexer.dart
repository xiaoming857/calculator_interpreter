enum TOKENS {
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
  SIN,
  COSEC,
  COS,
  SEC,
  TAN,
  COTAN,
  LOG,
  LN,
  MIN,
  MAX,
  AVG,
  ABS,
  FLOOR,
  CEIL,
  NUMBER,
  PI,
  E
}

RegExp numProp = RegExp(r'[0-9\.]');
RegExp isNum = RegExp(r'^\d$|^\d+\.?\d+$');
RegExp isLetter = RegExp(r'[a-zA-Z]');

// Operators
Map<String, TOKENS> operators = {
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
  'sin': TOKENS.SIN,
  'cosec': TOKENS.COSEC,
  'cos': TOKENS.COS,
  'sec': TOKENS.SEC,
  'tan': TOKENS.TAN,
  'cotan': TOKENS.COTAN,
  'log': TOKENS.LOG,
  'ln': TOKENS.LN,
  'min': TOKENS.MIN,
  'max': TOKENS.MAX,
  'avg': TOKENS.AVG,
  'abs': TOKENS.ABS,
  'floor': TOKENS.FLOOR,
  'ceil': TOKENS.CEIL,
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
      if (numProp.hasMatch(str[i])) {
        // Numbers
        while (i < str.length && numProp.hasMatch(str[i])) {
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
        while (i < str.length && isLetter.hasMatch(str[i])) {
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
          throw Exception('INVALID OPERATION(${temp})');
        }
      } else {
        // Invalid characters
        throw Exception('INVALID CHARACTER(${str[i]}) FOUND AT POSITION(${i})');
      }
    }
  }

  return tokens;
}