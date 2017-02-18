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
  is not an variable because it is not lower-case.
  
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
but not match the grammar of the language constructs.
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
  
  
Basic Part 1 (30%): Interpretation
==================================

There is a function called `Interpret` in [src/ast_interpret.cpp](src/ast_interpret.cpp)
which provides the skeleton of an interpreter for the language. Complete
the implementation, based on the semantics given earlier.

The test script `./test_interpreter.sh` applies the interpreter
to a number of different input programs in `test/programs`, and
checks that the outputs and results are correct. Note that by
default one of the tests [already passes](#43), as the skeleton
interpreter already handles numbers.


Basic Part 2 (30%): Code generation
==================================

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

Intermediate : Code analysis (20%)
================================

Compiler passes are often implemented as stages, and in
modern compilers may even be separate programs that read
in one representation of the program, then write out a
transformed program at the same level. 
In our language it is particularly easy to read in 
the AST, modify it, then write it back out again,
This kind of source-to-source optimisation process is quite
different to the classic lower-ing process, where we go from
C++ to C, or C to Assembly.

Implement three basic compiler optimisation passes:

- `bin/constant_fold` : An arithmetic constant folder, which
   optimises operators where both arguments are constants.
   For example, if we have:
   ````
   Sub [ x Add [ 4 5 ] ]
   ````
   it can be optimised to:
   ````
   Sub [ x 9 ]
   ````

- `bin/dead_branch_removal` : If an if condition is a constant,
  we can remove the branch that is not taken. For example, we
  can convert:
  ````
  Seq [ 
    Assign : y [ 5 ]
    If [ 0
      Assign : x [ 10 ]
      Assign : x [ 11 ]
    ]
  ]
  ````
  into:
  ````
  Seq [
    Assign : y [ 5 ]
    Assign : x [ 11 ]
  ]
  ````
  
- `bin/constant_propagation` : If a variable is assigned a constant
  value, we can rewrite all uses of that value to the constant, up
  until the next point the variable could be re-assigned. For example
  we can transform:
  ````
  Seq [
    Assign : x [ 5 ]
    Assign : y [ x ]
    Assign : x [ wibble ]
    Assign : z [ Add [ x 2 ] ]
  ]
  ```
  into:
  ````
  Seq [
    Assign : x [ 5 ]
    Assign : y [ 5 ]
    Assign : x [ wibble ]
    Assign : z [ Add [ x 2 ] ]
  ]
  ````
  Note that after the second assignment to x, we can no longer propagate. You
  need to be careful about assignments within If or While loops which may or
  may not happen. If you can't prove something won't happen, you must assume
  it will.
  
Each program should read its input from stdin, and write the
transformed tree to stdout. They should produce a return-value
of 0 (success) if they managed to simplify the tree, or 1 (failure)
if they are returning the tree unchanged. Either way, the tree
should still be written back out to stdout.

Comments
--------

It is worth observing that the first two of these optimisations are
reasonably straightforward. The third is straightforward to
implement in a naive way, but more difficult if you want to
sweep the constants to all the places where they still hold
(i.e. to get the maximum constant propagation distance). However,
it is much better to have less optimisation, than to get
incorrect code.
  
These optimisations are independent passes, but it is possible
that applying them sequentially may uncover more and more
optimisations. For example, if we start with:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ Add [ x y ] ]
  If [ z
    Output [ x ]
    Assign : x [ 0 ]
  ]
  x
]
```
then we can apply constant propagation on x:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ Add [ 10 y ] ]
  If [ z
    Output [ 10 ]
    Assign : x [ 0 ]
  ]
  x
]
```
then constant propagation on y:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ Add [ 10 20 ] ]
  If [ z
    Output [ 10 ]
    Assign : x [ 0 ]
  ]
  x
]
```
constant folding:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ 30 ]
  If [ z
    Output [ 10 ]
    Assign : x [ 0 ]
  ]
  x
]
```
constant propagation on z:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ 30 ]
  If [ 30
    Output [ 10 ]
    Assign : x [ 0 ]
  ]
  x
]
```
dead branch elimination on the If:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ 30 ]
  Output [ 10 ]
  x
]
```
and constant propagation on x again:
````
Seq [ 
  Assign : x [ 10 ]
  Assign : y [ 20 ]
  Assign : z [ 30 ]
  Output [ 10 ]
  10
]
```

On a big program it might make sense to run these in a loop,
and check the exit codes `$?` to see whether to keep going.
So something like:
```
#!/bin/bash

SRCFILE=$1  # Program to optimise

CHANGED=1;
while [[ "$CHANGED" -ne 0 ]]; do
  CHANGED=0;

  cat $SRCFILE | bin/constant_fold > $SRCFILE.tmp
  if [[ "$?" -eq "0" ]]; then
    CHANGED=1;
  fi
  cp $SRCFILE.tmp $SRCFILE
  
  cat $SRCFILE | bin/dead_branch_removal > $SRCFILE.tmp
  if [[ "$?" -eq "0" ]]; then
    CHANGED=1;
  fi
  cp $SRCFILE.tmp $SRCFILE
  
  cat $SRCFILE | bin/constant_propagation > $SRCFILE.tmp
  if [[ "$?" -eq "0" ]]; then
    CHANGED=1;
  fi
  cp $SRCFILE.tmp $SRCFILE
fi
```
(Initial version was intended to be a sketch, rather than
verbatim code; however, @fexter-svk [suggested changes](https://github.com/LangProc/langproc-2016-lab/issues/37) to
make it executable.

As long as the program keeps getting smaller, we might as
well keep optimising it. A natural question is "what if we
get stuck in an infinite loop?". Some reasoning suggests
that is not possible for our particular optimisations, as:

- constant_fold and dead_branch_removal make the AST strictly
  smaller, so there are fewer nodes afterwards than there were
  before.

- constant_propagation is a one-way process, as it only rewrites
  variables into numbers, not the other way round.

Taken together, that means that eventually the process must
stop, and reach a fixed-point.


Advanced : Program generation (20%)
===================================

Create a program called `bin/generate_mips`, that creates
an MIPS binary executable for a program in our language.

The usage should be:
````
$ make bin/generate_mips
$ bin/generate_mips test/programs/constant_5/in.code.txt my_executable
$ ./my_executable
$ echo $?
5
$
````

Some observations:

- You'll need to use a MIPS toolchain to do some parts of it (e.g.
  assembling and linking).

- The MIPS executable will only run if you have QEMU installed (or
  you're on a MIPS machine!)

- A program in UNIX doesn't _have_ to be a binary. As long as `bin/generate_mips`
  has the programmatic interface we want, it could be a script that
  calls other tools.

- This is a simplified version of what you'll have to for the final
  code generation. The main advantage here is that the set of code
  constructs and types is much smaller than in C.

- Generating MIPS assembly is not the only way of getting an executable...

Both the MIPS toolchain and QEMU are installed by default in both
the Lab Ubuntu setup and the Vagrant Ubuntu machine. If you are
using another platform/OS you'll need to work out how to install
them for your system.

Submission
==========

As before: commit, test, push to github, hash to blackboard.
