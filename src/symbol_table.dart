import 'ast.dart';
import 'errors.dart';


enum SCOPE_TYPE {
  GLOBAL,
  FUNCTION,
}


class SymbolTable {
  static int _currentScope = 0;
  static List<List<dynamic>> _table = [
    [SCOPE_TYPE.GLOBAL, '', Map<String, Node>()]
  ];


  static int get currentScope => _currentScope;


  static SemanticAnalyzerError enterScope(SCOPE_TYPE scopeType, String scopeName) {
    if (_table[_currentScope][1] == scopeName) {
      return SemanticAnalyzerError(lookUpScopes(scopeName), (Node node) => 'Cannot call function ${scopeName} as it contains function call that calls itself!');
    }
    _table.add([scopeType, scopeName, Map<String, Node>()]);
    ++_currentScope;
    return null;
  }
  

  static void exitScope() {
    if (_table.length > 1) {
      _table.removeLast();
      --_currentScope;
    }
  }


  static bool lookUpCurrentScope(String identifier) {
    return _table[_currentScope][2].containsKey(identifier);
  }


  static Node lookUpScopes(String identifier) {
    int currentScope = _currentScope;
    while (currentScope >= 0) {
      if (_table[currentScope][2].containsKey(identifier)) {
        return _table[currentScope][2][identifier];
      }
      --currentScope;
    }

    return null;
  }


  static void addSymbol(String identifier, Node value) {
    _table[_currentScope][2][identifier] = value;
  }


  static void showSymbols() {
    print(_table);
  }
}