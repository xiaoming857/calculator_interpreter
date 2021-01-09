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

### Example

#### Simple arithmetic expression

> Enter an expression: 1 + 2 * 3
>
> 
>
> TOKENS: [[TOKEN_TYPE.NUMBER, 1, [0, 0]], [TOKEN_TYPE.PLUS, +, [2, 2]], [TOKEN_TYPE.NUMBER, 2, [4, 4]], [TOKEN_TYPE.ASTERISK, *, [6, 6]], [TOKEN_TYPE.NUMBER, 3, [8, 8]], [TOKEN_TYPE.EOF, $, [9, 9]]]
>
> 
>
> AST: AST(BinOp(Number(1.0) Operator(+) BinOp(Number(2.0) Operator(*) Number(3.0))))
>
> 
>
> RESULT: 7.0

#### Assignment

> Enter an expression: a = 1
>
> 
>
> TOKENS: [[TOKEN_TYPE.IDENTIFIER, a, [0, 0]], [TOKEN_TYPE.EQUAL, =, [2, 2]], [TOKEN_TYPE.NUMBER, 1, [4, 4]], [TOKEN_TYPE.EOF, $, [5, 5]]]
>
> 
>
> AST: AST(Assignment(Identifier(a) = Number(1.0)))
>
> 
>
> RESULT: null

#### Function

> Enter an expression: func x(a) -> a + 1
>
> 
>
> TOKENS: [[TOKEN_TYPE.FUNCTION, func, [0, 3]], [TOKEN_TYPE.IDENTIFIER, x, [5, 5]], [TOKEN_TYPE.OPEN_PARENTHESIS, (, [6, 6]], [TOKEN_TYPE.IDENTIFIER, a, [7, 7]], [TOKEN_TYPE.CLOSE_PARENTHESIS, ), [8, 8]], [TOKEN_TYPE.ARROW, ->, [10, 11]], [TOKEN_TYPE.IDENTIFIER, a, [13, 13]], [TOKEN_TYPE.PLUS, +, [15, 15]], [TOKEN_TYPE.NUMBER, 1, [17, 17]], [TOKEN_TYPE.EOF, $, [18, 18]]]
>
> 
>
> AST: AST(Function(Identifier(x) Parameters([Identifier(a)]) -> BinOp(Identifier(a) Operator(+) Number(1.0))))
>
> 
>
> RESULT: null

#### Function Call

> Enter an expression: x(1)
>
> 
>
> TOKENS: [[TOKEN_TYPE.IDENTIFIER, x, [0, 0]], [TOKEN_TYPE.OPEN_PARENTHESIS, (, [1, 1]], [TOKEN_TYPE.NUMBER, 1, [2, 2]], [TOKEN_TYPE.CLOSE_PARENTHESIS, ), [3, 3]], [TOKEN_TYPE.EOF, $, [4, 4]]]
>
> 
>
> AST: AST(Function(Identifier(x) Arguments([Number(1.0)])))
>
> 
>
> RESULT: 2.0

#### Error

> Enter an expression: x ++ 1
>
> TOKENS: [[TOKEN_TYPE.IDENTIFIER, x, [0, 0]], [TOKEN_TYPE.PLUS, +, [2, 2]], [TOKEN_TYPE.PLUS, +, [3, 3]], [TOKEN_TYPE.NUMBER, 1, [5, 5]], [TOKEN_TYPE.EOF, $, [6, 6]]]
>
> AST: AST(null)
>
> RESULT: null
>
> 
>
> Error: Unexpected TOKEN_TYPE.PLUS at index [3:3]!</br>
>    x ++ 1</br>
>       ^
