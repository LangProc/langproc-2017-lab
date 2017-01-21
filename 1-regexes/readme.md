This lab is primarily focussed on lexers
and regular expressions. There are three components,
each of which has a separate sub-directory. When
working on each component, you should be working in
the relevant sub-directory (`a`, `b`, or `c`).

Initial repository setup
========================

Get the local working copy of your private repository:
````
git clone https://github.com/LangProc/langproc-2016-lab-${LOGIN}.git
````
You'll need to type in your github credentials to authenticate.

Move into the working directory:
````
cd langproc-2016-lab-${LOGIN}
````

### Adding files to the repository

Eventually you'll create files, and want them to be tracked
in the repository. So if you create a file `X/Y.Z`, and you want it to be tracked:
````
git add X/Y.Z
````
or you can use the interactive version:
````
git add -i
````
which allows you to select from the currently untracked files.

### Commits

When you reach particular milestones, or levels of functionality,
you should make a _commit_:
````
git commit -a -m "Comment about commit"
````
The `-a` tells it to "stage" (include) all the tracked files
into the commit. The message after `-m` should summarise what
has changed.

### Synchronising with your private GitHub repository

When you want to push the committed changes from your loval
repository back to github:
````
git push origin
````
and type in credentials when prompted. You can commit multiple
times before pushing, but you always have to commit at least
once for there to be something to push.

If you want to pull any changes down (for example if you've been
editing on two machines):
````
git pull origin
````

### Sychronising with the specification repository

If there are any changes to the master specification (e.g.
bugs or updates), you can incorporate them into your
version by pulling from the master. First you need to
make sure it is included as a "remote":
````
git remote add spec https://github.com/LangProc/langproc-2016-lab.git
````
If you now list the remotes, you should see both origin (your private
repo), and spec (the shared master):
````
git remote -v
````
You can now integrate changes from the spec remote by pulling
from it:
````
git pull spec master
````
If you have changed a file that also changed in the master,
then you may need to commit locally first. Look carefully
at any incoming changes due to the pull, and make sure you
want to accept them.

### General git comments

You are free to include any files you wish in your repository,
such as notes or partial versions. However, try not check in
compiled programs or large binary files. Repositories should
contains the sources and instructions for binaries, but git
does not deal well with binary files. Git repositories include
the history for all versions of all files, which works very
well for text files as it can just store delta changes. But
if you accidently include a binary file (e.g. a `.o` object),
then every time you commit a new copy of that file will be
stored in your repo.

There are many good GUIs for git, which are fine to
use as well the command line. They can make it easier to
select files to be added and commited, but try to be
selective about which files you add - don't just accept
everything they suggest, otherwise they'll tend to
include everything.

You may want to read the nodes on environments in the
main [readme](../readme.md), if you're interested in
replicating the test/lab environment at home or on
your laptop.

Basic: Histogramming (60%)
==========================

Problem
-------

Write a tool using Flex that reads an ASCII stream of text and:

- Calculates the sum of any _numbers_ in the text.

- Calculates a histogram of any _words_ in the text.

For our purposes we'll define words and numbers as:

- Any sequence of lower-case or upper-case alphabetic characters
  is a _word_.

- Any sequence of characters beginning with `"` starts a word,
  and the word ends at the next `"`. The word itself does not
  include the surrounding `"` characters. It is illegal for
  such a sequence to span a new-line.

- Any decimal number is a _number_. All numbers must start
  with a decimal digit, and may or may not contain a fractional
  part. Numbers may be negative.

All other characters should not be counted (and should not
appear in the output).

The output should be:

- One line containing the sum of the numbers. This should be
  printed in decimal, and have 3 fractional digits.

- A sequence of lines for each element in the dictionary,
  containing the word surrounded by speech marks, a space, then the decimal count.
  The lines should be sorted:
  - primary sort order: the number of times it occurs, from most to least.
  - secondary sort order: [lexicographic order](https://en.wikipedia.org/wiki/Lexicographical_order)
    of the words (this is just "normal" sorting of strings).

The program should be built using `make histogram` (ensure the
current working directory is `a`).

There is already a skeleton program setup, including:

- Flex source : [a/histogram_lexer.flex](a/histogram_lexer.flex)

- C++ driver program : [a/histogram_main.cpp](a/histogram_main.cpp)

- Makefile : [a/makefile](a/makefile)

The skeleton setup contains a number of comments suggesting where
things need to be changed and edited, but these are not exhaustive.

Examples
--------

Given the input:
````
abc 40 xyz 1 xyz -2
````
The output would be:
````
39.000
"xyz" 2
"abs" 1
````

Given the input:
````
a a a aa -67  -80 -6780 for while
"  x",, 52x
````
The output would be:
````
-6875
"  x" 1
"a" 3
"aa" 1
"for" 1
"while" 1
"x" 1
````

There is also a test-bench included, which is the complete
assessment script for this part of the lab. The components
are:


- [test/in](a/test/in) : A set of input test files of increasing complexity.
  Notice that it tries to test for specific circumstances and possible failure
  mores, before moving onto more general tests.

- [test/out](a_test/ref) : The "golden" output for the give input files, which
  your program should match. There is one output for each input.

- [test_lexer.sh](a/test_lexer.sh) : A [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) script which
  runs the tests. It will build your program, then apply it to each input in turn
  to produce a file in `test/out`. It will then use [diff](https://en.wikipedia.org/wiki/Diff_utility)
  to work out whether the output matches the reference output.

You can run the program by doing (from within the `a` directory):
````
./test_lexer.sh
````

Note that the [unix execute permissions](https://en.wikipedia.org/wiki/Modes_(Unix))
may have been lost, in which case you can indicate the script should be
executable with:
````
chmod u+x ./test_lexer.sh
````

Intermediate: C++ regexes (20%)
===============================

Overview
--------

Regular expressions are often used to implement transforms, by
using a regular expression with capture groups. For example,
this regular expression looks for two decimal numbers (`[0-9]+`),
separated by some other character (`[^0-9]`).
````
[^0-9]*([0-9]+)[^0-9]([0-9]+).*
````
As well as indicating grouping, the two parenthesised expressions
define two capture groups. We can then use a replacement
string to insert the capture groups into a new string. A common
tool used for this is [sed](https://en.wikipedia.org/wiki/Sed#Usage),
which uses the token `\1` to represent the first group, `\2` the second
group, and so on. For example, the replacement string:
````
\1,\2
````
would output the two groups separated by a comma. Given the
following input and the above combination of pattern and replacement
strings, the output would be:

Input       | Output
------------|-------------
1-1         | 1,1
12345x43    | 12345,32
why?,23-56  | 23,56
1-2-3-4-5   | 1,2

Most modern languages include support for both regular expressions
and replacements, including
[Javascript](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions),
[Python](https://docs.python.org/3.6/library/re.html),
[Rust](https://doc.rust-lang.org/regex/regex/index.html), and
[Go](https://golang.org/pkg/regexp/).
Support has also been included in C++ since [C++11](https://en.wikipedia.org/wiki/C%2B%2B11)
via the [`<regex>`](http://www.cplusplus.com/reference/regex/) library.

Problem
-------

Use C++ regular expressions to implement a text substitution
program, which takes lines of input from stdin, applies a
regex, transforms using a capture group, then prints the
resulting line back out. The overall requirements are:

- The program is built using `make regex_substitute` (from within the `b` directory).

- The program takes two command-line arguments:

  1 - The regex itself. These will be "basic" regular
      expressions, which are portable across all modern regex engines.

  2 - The replacement pattern. The substitution syntax should follow `sed` format

- Each line of input will be read from stdin.

- There is one line of output for each line of input

  - If the regex matches, the transformed version will be printed

  - If the regex does not match, the original line will be printed

Your program should have the same behaviour as the script
[regex_substitute_ref.sh](b/regex_substitute_ref.sh), which
you can use for testing. If you look inside the script, you can
see it simply invokes sed.

Example
-------

Here we show alternating input and output on each line:
````
$ ./regex_substitute "(ab|01)" "X\1X"
a
a
ab
XabX
01
X01X
ab_ab_01
XabX_XabX_X01X
10ba_ab_01
10ba_XabX_X01X
````

Another example:
````
$ ./regex_substitute "First[^a-z]*([a-z][a-z0-9]*).*[.]pdf" "\1.pdf"
First_dt10_v3.pdf
dt10.pdf
First_3.3_gac1.bak.pdf
gac1.pdf
First hes2 attempt.pdf
hes2.pdf
````

Suggestions
-----------

You'll need an outer read loop which works line by line. A
suggested function to use is [std::getline](http://www.cplusplus.com/reference/string/string/getline/).
The function returns the original stream, which allows for patterns like this:
````
std::string tmp;
while( std::getline(std::cin, tmp) ){
    // do something with line tmp
}
````

The C++ [regex](http://www.cplusplus.com/reference/regex/) library has a number
of modes and functions. Try to identify the function closest to the
behaviour you want.

We want replacement strings which match sed, which is not the default
in the C++ library, which prefers [ECMAScript](http://www.cplusplus.com/reference/regex/ECMAScript/).
However, it can be convinced to behave like sed if you read or search the documentation.

It might help to develop a set of test regular expressions, and for each
one create a few lines that match and a few that don't. You might wish
to adapt the test infrastructure from part `a` to help you, or create
some other simple way of checking that your program works.

Advanced: Regex implementation (20%)
====================================

Problem
-------

Implement a basic regex engine using C++. The
requirements are to create a program with the
following features:

- The program is built using the command `make bin/regex_engine` (in the directory `c`).

- The program takes as an input argument an ASCII regular expression,
  which can contain the following constructs:

  - Character literals (but not character ranges).
  
    - Character literals only include the alphabetic letters, numbers, and underscore,
      so each literal must match `[a-zA-Z0-9_]`.
    
    - The dot construct will not appear, as it is syntactic sugar for a character
      range containing all characters.

  - One-or-more (but not zero-or-more)

  - Grouping

  - Alternation

  Neither the regular expression nor input strings will contain whitespace.

- The program should read a sequence of input lines from stdin,
  and apply the regular expression to the line.

- Each input line should result in a corresponding output on stdout,
  which consists of either:

  - `Match` if the regular expression matches the _whole_ line

  - `NoMatch` if the regular expression does not match

Efficiency is not important (within reason!). So test inputs
are designed to have reasonable run-time, even if there is
a worst-case exponential execution time in the regex engine.

Example
-------

An example session would be (with input and output interleaved):

````
$ make bin/regex_engine
$ bin/regex_engine "ab+"
a
NoMatch
ab
Match
abb
Match
abab
NoMatch
````

Suggestions
-----------

First think of a data-structure to represent your regular expressions.
How does each fundamental construct map to your datastructure? Can you
manually build data-structures mapping to some example regular expressions?

Then try writing a "match" function, which takes a regular expression
data-structure and a string and tries to match the string. How do you
handle mis-matches? What happens if there are two alternatives to try?

Once you have got the data-structure working, then think about parsing
the regular expression into the data-structure.

You are free to use flex/bison if you want to for parsing the regular expression.

Submission
==========

Submission of code is via your git repository. Make sure
you have committed and pushed to github - you are _strongly_
encouraged to clone it into a different directory and then
test it, just in case you are relying on something that
wasn't commited.

Once your code is committed, note the [commit hash](https://blog.thoughtram.io/git/2014/11/18/the-anatomy-of-a-git-commit.html)
of your current revision:

````
git log -1
````
This will produce something like:
````
ubuntu@ubuntu-xenial:/vagrant$ git log -1
commit 94d8419b20c78da86415bea7236d3719915977a3
Author: David Thomas <m8pple@github.com>
Date:   Fri Jan 02 14:26:40 2017 +0000

    All tests passing.
````

The commit hash of this revision is `94d8419b20c78da86415bea7236d3719915977a3`
which is a cryptographic hash over all the files in your
repository, including the history of all the files. Because
the hash is cryptographically secure, it is impossible to
take one commit hash, then come up with a different
set of files which produces the same hash. The hash produced
on your local machine will also match the hash calculated
by github.

So take your hash (and just the hash), and submit it via blackboard.
This is proof of existence - even if github goes down, you
can later on prove that the existence of your hash in blackboard
means you must have done the work associated with the hash.
The hash in blackboard will also be the exact revision of your
repository that will get checked out of github and tested. So you
can carry on editing and modifying the repository, but only
the commit with the hash submitted to blackboard is the one tested.

To summarise:

1 - Test your code.

2 - Commit your code to your local repo.

3 - Note the commit hash (`git log -1`).

4 - Submit the hash via blackboard.

5 - Push the code to your github repo.

You can repeat this process as many times as you want,
up until the deadline.

