import 'ast.dart';


enum SCOPE_TYPE {
  GLOBAL,
  FUNCTION,
}


class SymbolTable {
  static int _currentScope = 0;
  static List<Map<String, Node>> _table = [
    {}
  ];


  static int get currentScope => _currentScope;


  static void enterScope() {
    _table.add(Map<String, Node>());
    ++_currentScope;
  }

  static void exitScope() {
    if (_table.length > 1) {
      _table.removeLast();
      --_currentScope;
    }
  }


  static bool lookUpCurrentScope(String identifier) {
    return _table[_currentScope].containsKey(identifier);
  }


  static Node lookUpScopes(String identifier) {
    int currentScope = _currentScope;
    while (currentScope >= 0) {
      if (_table[currentScope].containsKey(identifier)) {
        return _table[currentScope][identifier];
      }
      --currentScope;
    }

    return null;
  }


  static void addSymbol(String identifier, Node value) {
    _table[_currentScope][identifier] = value;
  }


  static void showSymbols() {
    print(_table);
  }
}