Basic: Parsing Maths (60%)
==========================

You will parse and build the AST for standard
maths notation over double-precision numbers. The
constraints on the input language are:

- _Operators_ to be supported are `+`, `-`, `*`, and `/`.

- Operators follow standard mathematical precedence.

- Operators are left-associative.

- Brackets `(` and `)` can be used to override [operator precedence](https://en.wikipedia.org/wiki/Order_of_operations).

- _Functions_ to be supported are `sqrt`, `exp`, and `log`.

  - Functions have one parameter, which _must_ be surrounded by
    parenthesis.
    
  - `exp` and `log` are both natural (base _e_).

- _Numbers_ are expressed as decimal numbers. These must
  start with an integer digit, may have a fractional part,
  and may be negative.

- _Variables_ are sequences of lower-case alphabetic
  characters.

- Apart from _operators_, _numbers_, _variables_, and _functions_,
  the only other characters will be white-space.

Your task is to build an AST, with the AST definitions provided
through [ast.hpp](include/ast.hpp). The classes are:

- [`Expression`](include/ast/ast_expression.hpp) : Provides the
  base class for the AST.

- [`Primitive`](include/ast/ast_primitives.hpp) : Sub-classes
  for handling variables and numbers.

- [`Operator`](include/ast/ast_operators.hpp) : Sub-classes
  for representing mathematical binary operators.

- [`Function`](include/ast/ast_functions.hpp) : Sub-classes
  for representing unary functions (`log`, `exp`, `sqrt`).

Some properties of the AST are:

- The AST lives in the heap, not on the stack. So in order
  to allocate a node representing 5.0, you would do:

  ````
  const Expression *expr = new Number(5.0);
  ````

- The AST is [immutable](https://en.wikipedia.org/wiki/Immutable_object), which
  means that once it is constructed it cannot be modified. Every function is
  `const`, and there are no exposed member variables, so there is no way of modifying
  the internals of a node after construction. This makes the semantics simpler,
  but then we can't modify the tree, we can only build a new one.

- Expressions are owned by the holder of the pointer to that expression.
  So in `Operator::Operator`, the constructor takes _ownership_ of
  the two sub-expressions, and will delete them when it is itself deleted
  in `Operator::~Operator`. This makes managing expression lifetimes easy,
  but means we can't share parts of the tree (For example, when rewriting
  a tree, we can't have the new tree point to parts of the old tree that are
  the same).

Your parser should complete the implemention of the function:
````
const Expression *parseAST();
````
which is declared in `ast_.hpp`, and defined in `parser.y`. This will parse the
input from `stdin` (the default source for Flex, which is providing tokens to
Bison), then return the AST.

There is a program called `bin/print_canonical`, which will
use the function `parseAST` to parse input, then print
it as a [canonical representation](https://en.wikipedia.org/wiki/Canonical_form).
You can build it using `make bin/print_canonical`.

The idea of a canonical form is that if two expressions are the same,
they should print to the same string. Here that is true _except_ for the floating-point
values, which are not printed to full precision. So for example, we might
find that two expressions print to `( 4.1 + x )` and `( 4.1 + x )`, but one expression
might be `(4.99999999 + x)`, and the other could be `(4.1000000001 + x)`.


Examples
--------

Given the input:
````
7+8
````
the code should do the equivalent of:
```
const Expression *expr = new AddOperator(
    new Number(7),
    new Number(8)
);
```
and the canonical printer will produce:
```
$ bin/print_canonical
7+8

( 7 + 8 )
```
Note that the input `7+8` can be terminated by using
`control+d` to indicate the [end of the input stream](https://en.wikipedia.org/wiki/End-of-Transmission_character).
This will cause the pretty-printer (or any program) to conclude that no
more input is going to arrive over `stdin`, and it should conclude its
work. Until the parser knows that there is no more input, it can't
return the AST, as if it sees the input `x`, it can't be sure it
won't be followed by arbitrary numbers of `+x` which make the expression longer.

When manually typing input the whitespace between input and output could
vary while still being correct. So it could look like this:
```
$ bin/print_canonical
7+8


( 7 + 8 )
```
if you hit return twice before the stream ends, or like this:
```
$ bin/print_canonical
7+8( 7 + 8 )
```
if you end the stream without pressing return. Generally you should
use typed input as a debugging and exploration tool, and rely more on automated
and repeatable tests from files for proper testing.

Given the input:
````
7*x +5*
 -5 * y
````
the code should do the equivalent of:
````
const Expression *expr  = new AddOperator(
    new MulOperator(
        new Number(7),
        new Variable("x")
    ),
    new MulOperator(
        new MulOperator(
            new Number(5),
            new Number(-5)
        ),
        new Variable("y")
    )
);
````
and the canonical printer will produce:
````
$ bin/print_canonical
7*x +5*
 -5 * y
 
( ( 7 * x ) + ( ( 5 * -5 ) * y ) )
$
````

Testing
-------

There is a script called `test_parser.sh`, which
applies the tests used during assessment. During
testing it will perform two tasks:

- Check that the expressions in [test/valid_expressions.input.txt](test/valid_expressions.input.txt)
  are parsed into the correct canonical string. The file consists of an input string
  and an output string, separated by a comma.

- Checks that the expressions in [test/invalid_expressions.input.txt](test/invalid_expressions.input.txt)
  are rejected by the parser.


Intermediate: Evaluation (20%)
==============================

The AST defines a function `Expression::evaluate`, which
takes a set of _variable bindings_, and evaluates
the expression. Here a variable binding is a `map`
from a variable name to a number: if we want to
evaluate the expression `x+y`, we would need to
pass in a map that gives bindings (numbers) for `x` and `y`.

Currently `Expression::evaluate` throws an exception.
Implement `evaluate` for the various parts of the AST,
and give the source for a program called `src/eval_expr.cpp`, and
which is built using `make bin/eval_expr`. This should
take a list of variable bindings on the command line,
where each binding is a variable and a number separated
by spaces, then evaluate an expression read from `stdin`.
The output should be written to 6 decimal digits.

Example
-------

Assume we have the expression `x+6`, and want to evaluate
it with `x=7`: The usage should be:
````
$ make bin/eval_expr
$ bin/eval_expr x 7
x+6
13.000000
$
````
Here the parts are:
- `$` : Command prompt of shell
- `bin/eval_expr x 7` : Command typed into bash/shell
- `x+6` : Input typed into stdin
- `13.000000` : Output printed to stdout

Another example:
````
$ bin/eval_expr a 4 b 7 c -3
(c+7)*b+c

25.000000
````

Advanced: Differentiation (20%)
===================================

The AST can be transformed into other ASTs by analysing
the tree. There is a function called `Expression::differentiate`,
which differentiates with respect to a value, and returns
the derivative as a new tree. Currently this is not implemented
and throws an exception.

Implement differentiation for the AST, and create a new program
called `src/diff_expr.cpp` that takes a set of one or more variables as
input parameters, and differentiates the sequence with respect to each variable.
The output should be a transformed expression that meets the
specifications of the input language.

_Note that this program does not have a unique correct output.
There are an infinite number of correct ASTs that are equivalent
(why?), and any one of them could be output as an infinite
number of strings (why?)_

For example:
````
$ make bin/diff_expr
$ bin/diff_expr x y x
x*(x+2*y)*x/z*x + y *x
12*x/z
$
````

No simplification of the output expressions is required, nor
is it an error to (correctly) simplify the results.

Submission
==========

As before ensure you have committed your code, then do
a full test. Then push your code to your private github
repo, and submit the commit hash to blackboard.
