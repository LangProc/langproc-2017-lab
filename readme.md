Lab exercises for Language Processors 2017/2018
===============================================

This repository contains the specification for
the three lab exercises for Language Processors.
The three exercises are equally weighted, and
are worth 33.3% of your computing lab mark.

The primary purpose of the lab sessions is to ensure
that everyone learns the basic skills needed for the
coursework. They are not designed to be challenging,
but they do require you to get to grips with a number
of tools and concepts that you will need later.

The three exercises are:

1 - [Lexers and regular expressions](1-regexes) : Due Tue 30th Jan at 22:00.

2 - [Parsers and ASTs](2-parsers) : Due 13th Feb at 22:00.

2 - [Code Generation](3-codegen) : Due 27th Feb at 22:00.

The code for each exercise will be submitted via github,
and the hash of the commit to be tested will be submitted
via blackboard (see the [notes in exercise 1](1-lexer/readme.md#Submission)).

Assessment and Feedback
=======================

The intent is that the specifications are precise, so
the marking will be quantitative, and feedback will
largely be in terms of what works and what doesn't.
The formal feedback should contain enough information
to understand why specific parts don't work, in terms of
inputs and the resulting errors, and why you got the mark you got.

This is all "normal" coursework, so the expectation
is that you'll be getting all feedback within 10
working days (hopefully before...). As a consequence,
there will be no manual intervention in submitted
code - it is up to you to make sure it compiles and
runs!

Where there is ambiguity in the spec, please raise an
issue and DBT will be happy to refine/clarify (though
do it _before_ the deadline!).

Formative feedback is also available, from:
- The lab helpers
- The course module leader
- Your tutors
- Your peers

However, it is up to you to be pro-active and
indicate what you want feedback on. If there
is a test-case and you can't understand why
it failed, then ask someone. But don't expect
them to do all the work - ideally you should be able
to first explain all the ideas you had about why it
might have failed, and then why none of those ideas
were correct.

You may also want feedback on code quality or
structure, which is a good thing. However, given
the general question "What should I do to improve my code",
the standard response is just going to be one or
more of:
- Add more tests
- Refactor to remove duplicated code
- Refactor large functions into smaller ones
- Improve your commenting style
- Use better variable/function names
- Stop using global variables
- Stop using `#define`
- Don't use [magic numbers](https://en.wikipedia.org/wiki/Magic_number_(programming)#Unnamed_numerical_constants),
  use named constants
- Make sure you free everything you new
- Read the compiler warnings and get rid of them

You'll often get much more useful feedback if you
try to phrase things in terms of design choices.

- Try to identify points in your code or
  overall design that could have been done differently,
  or you weren't sure about at the time.

- Think through the choices again, particularly with
  hindsight.

- Discuss the choices with someone.

As your programming ability improves, it becomes more
about evolving your personal style and intuition.
Beyond some level of code complexity, you'll find that
"What should I do to improve my code" will start to mean
"What should I do to make my code look more like your code?".
If you ask an academic who likes OOP what to do, they'll
suggest more objects. If you ask a post-doc who likes functional,
they'll suggest more functions. One of your peers will
probably say you should use nodejs, for no particular reason.

Instead you should try
engage in a discussion about the pros and cons of
OOP vs functional (or whatever choice you were facing)
in the specific context of your program and what
you're trying to do.

Environment
===========

The target environment for this lab (and the coursework)
is Ubuntu 16.04. It is strongly suggested that you do your
final testing before each submission in the same environment,
otherwise you are likely to hit incompatibility problems, which
may mean your program won't build. Those on OSX should
watch out in particular, as the build environment is
often subtly different.

If you want to work on your own machines (which is a good
idea), you can install a version of Ubuntu quite easily.
However, rather than a full-on install-from-iso, you
may wish to consider using [VirtualBox](https://www.virtualbox.org/)
together with [Vagrant](https://www.vagrantup.com/).

This repository contains a [Vagrantfile](Vagrantfile) which
contains configuration information for the environment
and tools used in this lab. So in order to start a virtual
machine using Vagrant:

- Open a shell at this directory

- `vagrant up`

- Wait: it will download the VM image, then install and configure
  the virtual machine

- `vagrant ssh`

- `cd /vagrant` : This will put you in the same directory, with
  your host files shared with the VM.

You can then use command line build tools in the VM, while editing
the source files in your host editor.

If you want to stop the machine, `exit` the session, then do
`vagrant halt`. If you later to `vagrant up` again, it will
not need to download the VM again. If you want to save the
disk-space, do `vagrant destroy`.

The contemporary approach to VMs is that they should be
quick to start and configure, and you should not be
afraid to destroy them. Just make sure your work is
on the `/vagrant` directory of the VM, as that is the
part shared with the host drive.



