# Calculator Interpreter - SÒAN

A simple calculator interpreter implemented using Dart programming language.

### Features

- Basic arithmetic calculation:
  - Addition & Subtraction
  - Multiplication, Division, & Modulo
  - Exponential
  - Parentheses use case in precedence
- Variable assignment
- Function
- Error handling

### Specification

- Terminal application
- To end the program, close the terminal
- Do not support data type
- Function recursion has been prevented
- Function accepts at least one parameter and always return a number
- All numbers are decimals. If integer is being inputted, it will be converted into decimals
- Numbers can be assigned to variables that store function, the function will simply be replaced by the number. This also works the way around.

### Tokens

| Type              | Symbol                                          | Explanation                                                  |
| ----------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| EOF               | \$                                              | Marks the end of string                                      |
| IDENTIFIER        | \^\[a\-zA\-Z\_\]\+\[a\-zA\-Z\\d\_\]\*\$         | Any words that follows the rule of variable:<br />- Any alphabetical character<br />- Can have underscores<br />- Number can only appear after preceded by at least an underscore or identifier |
| NUMBER            | \^\(0\$\|\[1\-9\]\+\)\\d\*\$\|\^\\d\+\\.\\d\+\$ | Accepts decimals, all numbers will be converted into doubles |
| FUNCTION          | func                                            | The keyword for function declaration                         |
| ARROW             | \-\>                                            | Separator between function header and function body, similar to return |
| COMMA             | ,                                               | Separator between arguments or parameters                    |
| EQUAL             | \=                                              | Used in assignment                                           |
| PLUS              | \+                                              | Used in addition                                             |
| MINUS             | \-                                              | Used in both subtraction and negative numbers                |
| ASTERISK          | \*                                              | Used in multiplication                                       |
| SLASH             | /                                               | Used in division                                             |
| PERCENT           | %                                               | Used in modulo                                               |
| CARET             | \^                                              | Used in exponential                                          |
| OPEN_PARENTHESIS  | \(                                              | Marks the importance in precedence and marks the beginning of parameters or arguments |
| CLOSE_PARENTHESIS | \)                                              | Ends the open parenthesis                                    |

### Grammars

| Non-terminal     | Terminal                                                     |
| ---------------- | ------------------------------------------------------------ |
| pStart           | pDeclaration<br />\| pStatement<br />\| pExpression          |
| pDeclaration     | $func$ pIdentifier $($ pParameter $)$ $->$ pExpression       |
| pStatement       | $id =$ pExpression                                           |
| pExpression      | pTerm pExpressionPrime                                       |
| pExpressionPrime | $+$ pTerm pExpressionPrime<br />\| $-$ pTerm pExpressionPrime<br />\| $\epsilon$ |
| pTerm            | pPower pTermPrime                                            |
| pTermPrime       | $*$ pPower pTermPrime<br />\| $/$ pPower pTermPrime<br />\| % pPower pTermPrime<br />\| $\epsilon$ |
| pPower           | pFactor pPowerPrime                                          |
| pPowerPrime      | ^ pFactor pPowerPrime                                        |
| pFactor          | $num$<br />\| $id$<br />\| $-$ pExpression<br />\| $($ pExpression $)$ |
| pParameter       | pIdentifier pParameterPrime                                  |
| pParameterPrime  | $,$ pIdentifier pParameterPrime                              |
| pArgument        | pExpression pArgumentPrime                                   |
| pArgumentPrime   | $,$ pExpression pArgumentPrime                               |
| pIdentifier      | $id$                                                         |

