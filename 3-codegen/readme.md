You will interpret a simple imperative AST, then generate
equivalent code for a simple infinite-register ISA.

Input language
==============

The input language provides a basic set of constructs, which
support both statements and expressions. A simple example which
prints the numbers from 10 down to 1 is:

    Seq [
      Assign : x [ 10 ]
      While [ LessThan [ 0 x ]
        Seq [
          Output [ x ]
          Assign : x [ Sub [ x 1 ] ]
        ]
      ]      
    ]

The equivalent C would be:

    {
      x = 0;
      while(0 < x)
      {
        printf("%d\n",x);
        x = x - 1;
      }
    }

The language has the feature that variables do not need to
be declared, so the variable `x` is declared when it
is first assigned.

As a consequence of not requiring declarations, this language
also only has a single global scope. So the variable `x` always
refers to the same variable, no matter where it is used. This
behaviour is chosen to make the problem simpler for the lab; obviously
in C you'll need to manage different scopes in some way. (_Thanks
to @lorenzo2897 for [pointing out](https://github.com/LangProc/langproc-2016-lab/issues/40) this
wasn't explicit).


Language Constructs
-------------------

Input/Output is built into the language, with four types of input-output
modelled on the IO of a command-line process:

- Parameters : a vector of integers passed to the program,
  equivalent to command line parameters (`argv`).

- Input : a stream of integers, equivalent to reading integers from `std::cin`.

- Output : a stream of integers, equivalent to writing integers to `std::cout`.

- Return-value : a single integer return value, equivalent to the return-value of
 `main`, or the parameter passed to `exit`.

Input programs can contain the following constructs:

- Number: `decimalNumber`
  
  A number is a decimal number consisting of decimal digits and an optional
  sign (`-?[0-9]+`). When evaluated it returns the given number.

- Variable: `variable`

  A variable matches the regex `[a-z][a-z0-9]*. It returns the value of the variable,
  which must already have been given a value elsewhere in the program. All variables
  appear at global scope, so a variable `x` will always refer to the same variable,
  no matter where it appears.
  
- Input: `Input`

  Reads an integer from the input stream of numbers and returns it. Note that it
  is not a variable because it is not lower-case.
  
- Param : `Param : I`

  Return the input parameter with index I.
  
- Output: `Output [ X ]`

  Evaluate X, then send the result to output. The return value
  is the value of X.
  
- LessThan : `LessThan [ A B ]`

  Evaluate A then B; return non-zero if A < B.

- Add : `Add [ A B ]`

  Evaluate A then B; return A + B.
  
- Sub : `Sub [ A B ]`

  Evaluate A then B; return A - B.
  
- Assign : `Assign : N [ V ]`

  Evaluate expression V, and assign it to variable N. The return
  value is the value of V.

- Seq : `Seq [ X Y ... ]`

  Executes X, then Y, and so on. Return value is that of
  the last thing executed.
  
- If : `If [ C X Y ]`

  If evaluating C returns non-zero then execute and return X,
  else execute and return Y.

- While : `While [ C X ]`
  
  As long as C evaluates to non-zero, execute X.
  Return value is zero (as C will be the last part evaluated).
  
Notice that the language has the property that _all_ constructs
return a value, so everything can be considered to be an expression.
However, any expression can also have side-effects, i.e. it could
modify a variable.
 
There are a number of input programs in `test/programs/*/in.code.txt`,
which perform some simple calculations. If you mentally
translate them to C, the meaning should be clear.

Data representation
-------------------

The language is designed to have an extremely lightweight and
direct mapping to an AST, which allows for a very simple lexer
and parser. The entire parser is contained in [src/ast_parse.cpp](src/ast_parse.cpp),
which contains:

- `Tokenise` : Turns an input character stream into a sequence of
  tokens, simply by splitting on whitespace.
 
- `Parse` : A recursive-descent parser which implements a complete
  parser in ~40 lines of code.

This brevity is achieved by using a generic AST, which can represent any
tree, but does not have classes for each node type. Instead, each
tree node has:

- `type` : what type of node it is, or the name/value
- `value ` : An optional string representing a value at this node
- `branches` : A vector of zero or more sub-trees.

We'll use the following representation:

- Tree of type "xyz", with no value or branches.
    ````
    xyz
    ````

- Tree of type "x" with value "y", and no branches.
    ````
    x : y
    ````

- Tree of type "wibble", with no value and two sub-branches:
    ````
    wibble [
        a : 5
        b : 7
    ]
    ````

- Tree of type "wobble", with a value "hello" and one sub-branch. The
  sub-branch has type "a" and has neither value nor sub-branches.
    ````
    wibble : hello [
        a
    ]
    ````

This representation is similar to the approach taken in
JSON or XML, where there is a general-purpose heirarchical data-structure,
then meaning is imposed onto it at a higher level. In this
case, there are many ASTs which are syntactically correct,
but do not match the grammar of the language constructs.
This approach is also taken
in [homoiconic](https://en.wikipedia.org/wiki/Homoiconicity) languages,
such as Lisp, Clojure and Julia, where code-is-data-is-code.
As with such languages, a dis-advantage is that we don't
discover that an AST is mal-formed at parse-time - it only
becomes apparent when we try to work with the tree.

Meta-comment on data-structures
-------------------------------

Unlike the strongly OOP approach taken with the maths parser,
this representation encourages a separation of data-structure and
code. We cannot add virtual methods to the nodes, as there is only
one node type, so must instead choose different code paths by
manually switching on the node type. This naturally leads to
a recursive approach, with explicit recursion and pattern-matching,
rather than polymorphic dispatch and implicit recursion.

A simple of example of this is the pretty-printer in [src/ast_pretty_print.cpp](src/ast_pretty_print.cpp),
which recursively walks down the tree, directly calling itself
for each sub-branch. Notice that the pretty-printer wouldn't
care if we added new program constructs - for example, if we
added a new language construct `For [ V N S ]`, the pretty-printer
would happily print it without knowing what it means.

The reason for using this AST here is to allow you to contrast
between the strongly OOP approach of classes and sub-classes
where functionality is strongly bound to data, versus a more
data-oriented where functionality is separate from data. The two
approaches each have advantages, but are particularly highlighted
by this thought experiment: imagine you had an AST which has
N node types (e.g. Variable, Number, AddOp, LogFunc, ...) and M functions
(e.g. Print, Save, TypeCheck, Interpret, ...). Would you
prefer to have an OOP or generic AST if you had to:

- Add a new function?

- Add a new node type?

How many different places in the code would you need to edit,
and how many cases would have to be handled?

This is an example of the [Expression problem](https://en.wikipedia.org/wiki/Expression_problem),
which is both:

- a long-standing problem in computer-science resulting in languages
  and theoretical results which have no immediate relevance to the real world.
  
- a critically important aspect of real world program design which can
  mean the difference between a code-base that is easy to maintain and
  extend, versus a code-base that grows quadratically over time.
  
  
Task: Interpretation
==========================

There is a function called `Interpret` in [src/ast_interpret.cpp](src/ast_interpret.cpp)
which provides the skeleton of an interpreter for the language. Complete
the implementation, based on the semantics given earlier.

The test script `./test_interpreter.sh` applies the interpreter
to a number of different input programs in `test/programs`, and
checks that the outputs and results are correct. (By default, one
of the test-cases passes already).


Task: Code generation
=====================

The file `src/vm.cpp` implements a simple virtual
machine which uses a MIPS-like ISA, but with an
infinite register file. 

The supported assembly instructions are:

- `:label` : Establishes a label (jump target)

- `const dstReg immVal` : Loads the decimal immediate value into the destination register

- `input dstReg` : Read a value from input, and put it into the destination register.

- `param dstReg immVal` : Place the input parameter with index immVal into destination register.

- `output srcReg` : Write the value in source register into the output stream.

- `add dstReg srcRegA srcRegB` : Add the two source registers and write to destination.

- `sub dstReg srcRegA srcRegB` : Subtract the two source registers and write to destination.
        
- `lt dstReg srcRegA srcRegB` : If srcRegA < srcRegB, then dstReg=1, otherwise dstReg=0.

- `beq srcRegA srcRegB label` : If srcRegA == srcRegB, then jump to label.

- `bne srcRegA srcRegB label` : If srcRegA != srcRegB, then jump to label.

- `halt srcReg` : Halt the program and return value in srcReg.

A limitation of the current VM is that labels and register names cannot be
larger than 63 characters, and may [silently truncate off extra characters](https://github.com/LangProc/langproc-2016-lab/issues/47).

The vm can be compiled with
````
make bin/vm
````
and launched as follows:
````
bin/vm pathToAssembly Param0 Param1 ...
````
The input stream comes from `stdin`, and output goes to `stdout`.

An example program which copies input to output while adding
1 each time is:
````
const zero 0
const one 1
:top
input i
beq i zero bottom
add i i one
output i
beq one one top
:bottom
halt zero
````
The program stops copying when an input of 0 is encountered.

Problem
-------

The program `bin/compiler` can be built using `make bin/compiler`,
and is a compiler from the input language to the vm assembly
language. It relies on a function called `Compile` in `src/ast_compile.cpp`,
which is only partially complete. Complete the function so that
it can compile all code constructs.

The test script `./test_compiler.sh` applies the compiler
to the existing input programs in `test/programs` to get
the assembly, then passes it through the virtual machine.
The interpreted program and the compiled program should
provide the same output.


Submission
==========

As before: commit, test, push to github, hash to blackboard.
