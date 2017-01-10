Overview of Sed
---------------

Sed is a well-known tool for text processing. It has
has many features (see [tetris in Sed](https://github.com/uuner/sedtris)),
but it is often used for its regular expression support. A simplified
template for using `sed` is:

    sed -E -e "s/YOUR_REGEX/YOUR_REPLACEMENT/g"

The components here are:

- `-E` : Enable [extended regular expressions](https://www.gnu.org/software/sed/manual/sed.html#ERE-syntax).
  ERE requires less escaping than the basic form, and are the basis for
  most regex languages

- `-e` : Indicates an expression to apply will come next

- `"s/YOUR_REGEX/YOUR_REPLACEMENT/g"` : The expression that will be applied

  - `s` : Indicates this is a search and replace expression

  - `YOUR_REGEX` : The regular expression to look for

  - `YOUR_REPLACEMENT` : What to replace any matches with

  - `g` : This should be applied globally. If g is not present,
    only the first match on a line is replaced.

As an example, try running:

    sed -e "s/x/y/g"

The program will read from standard input and write to standard
output, so it will wait for you to type lines in. Type in a line
of text then press return - you should see the line echoed
back out, but any `x`s will be replaced with `y`. You can
put in multiple lines (press return after each), and this
is one way of debugging regexes interactively.

Here are some other examples to try. Try to anticipate
what they do, then type in lines that will cause the
replacement to happen or not happen.

- `sed -e "s/abc/xyz/g"

- `sed -e "s/a+/b/g"

- `sed -e "s/x|y/xy/g"

- `sed -e "s/[0-9]+/ X\1X /g"

For more documentation, see:

- The GNU Sed [manual](https://www.gnu.org/software/sed/manual/sed.html).

- The Wikipedia [sed page](https://en.wikipedia.org/wiki/Sed)

- Grymoire [sed tutorial](http://www.grymoire.com/Unix/Sed.html)
