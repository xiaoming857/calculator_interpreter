import 'ast.dart';
import 'errors.dart';


/// Scope types
/// - GLOBAL: the base of scopes, all scopes can access it
/// - FUNCTION: scope within a function, can be accessed only within the function
enum SCOPE_TYPE {
  GLOBAL,
  FUNCTION,
}


/// The [SymbolTable] class is the symbol table for storing assignments and declarations symbol.
class SymbolTable {
  /// The current scope, by default is 0 - a global scope
  static int _currentScope = 0;

  /// List of symbols. The scopes is in a form of list where:
  /// - index 0 is the type of the scope
  /// - index 1 is the name of the scope (same as the variable that stores them)
  /// - index 2 contains the assignments and declarations
  /// 
  /// A new symbol will be inserted upon entering a new scope.
  /// And so does the last symbol will be removed when exiting the scope. Index 0 belongs to
  /// global scope and this symbol must not be removed.
  static List<List<dynamic>> _table = [
    [SCOPE_TYPE.GLOBAL, '', Map<String, Node>()]
  ];

  /// Getter
  static int get currentScope => _currentScope;


  /// [enterScope] method is called when entering a scope. It accepts 2 parameters:
  /// - scopeType, the type of the scope
  /// - scopeName, the name of the scope. Leave it as an empty string ('') in case it does not have any name.
  static SemanticAnalyzerError enterScope(SCOPE_TYPE scopeType, String scopeName) {
    // Checking that prevent recursion
    if (_table[_currentScope][1] == scopeName) {
      return SemanticAnalyzerError(lookUpScopes(scopeName), (Node node) => 'Cannot call function ${scopeName} as it contains function call that calls itself!');
    }
    _table.add([scopeType, scopeName, Map<String, Node>()]);
    ++_currentScope;
    return null;
  }
  

  /// [exitScope] is called when exiting a scope. It will stop when the current scope is global scope.
  static void exitScope() {
    if (_table.length > 1) {
      _table.removeLast();
      --_currentScope;
    }
  }


  /// Look for identifier in current scope
  static bool lookUpCurrentScope(String identifier) {
    return _table[_currentScope][2].containsKey(identifier);
  }


  /// Look for identifier in all scope
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


  /// [addSymbol] adds a new identifier along with its value in the current scope
  static void addSymbol(String identifier, Node value) {
    _table[_currentScope][2][identifier] = value;
  }


  /// Print out [ _table]
  static void showSymbols() {
    print(_table);
  }
}