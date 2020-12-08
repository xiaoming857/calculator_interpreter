import '../src/lexer.dart';
import '../src/parser.dart';


bool check(List<Map<TOKEN_TYPE, String>> tokens, double result) {
  return result == Parser().parse(tokens);
}

void main() {
  Map<List<Map<TOKEN_TYPE, String>>, double> tests = {
    [{TOKEN_TYPE.NUMBER: "3"}, {TOKEN_TYPE.MULTIPLY: "*"}, {TOKEN_TYPE.NUMBER: "2"}, {TOKEN_TYPE.POWER: "^"}, {TOKEN_TYPE.NUMBER: "3"}, {TOKEN_TYPE.ADD: "+"}, {TOKEN_TYPE.NUMBER: "7"}, {TOKEN_TYPE.DIVIDE: "/"}, {TOKEN_TYPE.NUMBER: "2"}, {TOKEN_TYPE.SUBTRACT: "-"}, {TOKEN_TYPE.NUMBER: "1"}, {TOKEN_TYPE.EOF: "\$"}] : 26.5
  };
  
  int i = 1;
  tests.forEach((input, result) {
    bool isValid = false;

    try {
      isValid = check(input, result);
    } catch (e) {
      print(e);
      isValid = e.toString() == result;
    }

    if (!isValid) {
      print('Check number ${i}:[${input}] is invalid!');
    }
    i++;
  });
}