Informal pulls
==============

We'll do some informal pulls so that people can get an idea about
build or execution failures. These are not required deadlines,
so don't worry if you don't have anything in (well, worry a bit).

The proposed schedule is:
- Wednesday 24th, 22:00
- Friday 26th, 22:00

Some notes on these kinds of runs:

- The hash will come out of blackboard in order to determine
  which commit to test.

- These are completely informal runs, and there is no particular
  guarantee associated with exactly when they are run, or when you'll
  get the results back. If the build system falls asleep, they won't
  happen until the morning. The only point of putting times is to give
  some idea of when things will be captured. 

- There is not implication of promise this will happen for all labs.

- No human will look at the output of these tests, unless the
  recipient cares to look.

- You may wish to subscribe to your repository (if you haven't
  already), so that you'll see when content appears.

Overview
========

This lab is focussed on lexers and regular expressions, and is intended to
give you enough working knowledge and experience to design and implement
the C lexer for your compiler.

Initial repository setup
========================

Get the local working copy of your private repository:
````
git clone https://github.com/LangProc/langproc-2017-lab-${LOGIN}.git
````
You'll need to type in your github credentials to authenticate, unless
you've set up SSH authentication.

Move into the working directory:
````
cd langproc-2017-lab-${LOGIN}
````

Everyone has plenty of experience with git from last term, but I'll
summarise the main ideas briefly again.

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

When you want to push the committed changes from your local
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
git remote add spec https://github.com/LangProc/langproc-2017-lab.git
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
stored in your repo. Most repositories should contain a
[.gitignore](https://git-scm.com/docs/gitignore) file, which
gives patterns for files that should not be commited. There
is [one included here](.gitignore) which covers a few things, 
but feel free to add other temporary and binary files that
your system might produce.

There are many good GUIs for git, which are fine to
use as well the command line. They can make it easier to
select files to be added and commited, but try to be
selective about which files you add - don't just accept
everything they suggest, otherwise they'll tend to
include everything.

You may want to read the notes on environments in the
[main readme](../readme.md), if you're interested in
replicating the test/lab environment at home or on
your laptop.


Specification
=============

Write a tool using Flex that reads an ASCII stream of text and:

- Calculates the sum of any _numbers_ in the text.

- Calculates a histogram of any _words_ in the text.

For our purposes we'll define words and numbers as:

- Any sequence of lower-case or upper-case alphabetic characters
  is a _word_.

- Any sequence of characters beginning with `[` starts a word,
  and the word ends at the next `]`. The word itself does not
  include the surrounding `[` or `]` characters. It is illegal for
  such a sequence to span a new-line.

- A number can be expressed as a _decimal_ or as a _fraction_.

- An decimal is a contiguous sequence of decimal digits, preceded
  by an optional `-` sign, and optionally followed by a `.` sign and
  zero or more decimal digits  It should be interpreted as a decimal
  double-precision number.

- A fraction consists of an optional leading `-` sign, a sequence
  of decimal digits, a `/` sign, and another sequence of decimal
  digits. It should be interpreted by converting the two digits sequences
  as decimal integers, then taking the ratio using double-precision.
  
- Fractions with [zero denominators](https://github.com/LangProc/langproc-2017-lab/issues/55)
  are illegal, so implementations can handle them however is convenient,
  and they will not appear in any test inputs (thanks to @VasiliosRallis).

- If a sequence of characters could be interpreted as an decimal
  or a fraction, then fraction should have precedence.

All other characters should not be counted (and should not
appear in the output).

The output should be:

- One line containing the sum of the numbers. This should be
  printed in decimal, and be correct to at least 3 fractional digits.

- A sequence of lines for each element in the dictionary,
  containing the word surrounded by square brackets, a space, then the decimal count.
  The lines should be sorted:
  - primary sort order: the number of times it occurs, from most to least (_note: originally
    this text did not match the code - thanks to @patrickjohncyh for [pointing this out](https://github.com/LangProc/langproc-2017-lab/issues/55)_).
  - secondary sort order: [lexicographic order](https://en.wikipedia.org/wiki/Lexicographical_order)
    of the words (this is just "normal" sorting of strings).

The program should be built using `make histogram`.

There is already a skeleton program setup, including:

- Flex source : [histogram_lexer.flex](histogram_lexer.flex)

- C++ driver program : [histogram_main.cpp](histogram_main.cpp)

- Makefile : [makefile](makefile)

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
[abc] 1
[xyz] 2
````

Given the input:
````
a a a aa -67 1/2  -80 -6780.0  64/8 for while
[  x],, 52x
````
The output would be:
````
-6866.500
[  x] 1
[aa] 1
[for] 1
[while] 1
[x] 1
[a] 3
````

There is also a test-bench included, which is a partial
set of test vectors for the program. Passing these tests
is equivalent to achieving 50% in the final assesment,
with unseen tests covering the remaining 50%.

The components of the test are:

- [test/in](test/in) : A set of input test files of increasing complexity.
  Notice that it tries to test for specific circumstances and possible failure
  mores, before moving onto more general tests.

- [test/out](test/ref) : The "golden" output for the give input files, which
  your program should match. There is one output for each input.

- [test_lexer.sh](test_lexer.sh) : A [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) script which
  runs the tests. It will build your program, then apply it to each input in turn
  to produce a file in `test/out`. It will then use [diff](https://en.wikipedia.org/wiki/Diff_utility)
  to work out whether the output matches the reference output.

You can run the program by doing:
````
./test_lexer.sh
````

Note that the [unix execute permissions](https://en.wikipedia.org/wiki/Modes_(Unix))
may have been lost, in which case you can indicate the script should be
executable with:
````
chmod u+x ./test_lexer.sh
````
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

1 - Test your code on your machine.

2 - Commit your code to your local repo.

3 - Note the commit hash (`git log -1`).

4 - Push the code to github.

5 - Check the commit hash in the github web-site matches your local hash.

6 - **Strongly suggested**: clone your code to a completely different directory,
    and test it again.

7 - Submit the hash via blackboard.

You can repeat this process as many times as you want,
up until the deadline.

