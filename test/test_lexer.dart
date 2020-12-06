import '../src/lexer.dart';


bool check(String input, String result) {
  return result == Lexer.getTokens(input).toString();
}

void main() {
  Map<String, String> tests = {
    // Check a valid expression
    '100 + 100 - 1.0 * 10 / 0.5': '[{TOKEN_TYPE.NUMBER: 100}, {TOKEN_TYPE.ADD: +}, {TOKEN_TYPE.NUMBER: 100}, {TOKEN_TYPE.SUBTRACT: -}, {TOKEN_TYPE.NUMBER: 1.0}, {TOKEN_TYPE.MULTIPLY: *}, {TOKEN_TYPE.NUMBER: 10}, {TOKEN_TYPE.DIVIDE: /}, {TOKEN_TYPE.NUMBER: 0.5}, {TOKEN_TYPE.EOF: \$}]',

    // Check empty number after (.)
    '1. + 1': 'Exception: INVALID NUMBER(1.)',

    // Check empty number before (.)
    '1 + .1': 'Exception: INVALID NUMBER(.1)',

    // Check invalid character (`)
    '1 + `': 'Exception: INVALID CHARACTER(`) FOUND AT POSITION(2)',

    // Check invalid keyword (asd)
    'asd': 'Exception: INVALID FUNCTION(asd)',
  };
  
  int i = 1;
  tests.forEach((input, result) {
    bool isValid = false;

    try {
      isValid = check(input, result);
    } catch (e) {
      isValid = e.toString() == result;
    }

    if (!isValid) {
      print('Check number ${i}:[${input}] is invalid!');
    }
    i++;
  });
}