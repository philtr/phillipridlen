---
layout: post

date: 2008-12-05

title: "The Smart Kid With No People Skills"
subtitle: "Thoughts on Haskell"
---

Remember that kid from fourth grade who was already working out calculus
problems during recess, but when he was asked to answer a question in class he
stumbled over his words and gave an answer that was too confusing or disjointed
to understand?

Well, that’s kind of what Haskell is. According to its website,

> Haskell is a general purpose, purely functional programming language
> incorporating many recent innovations in programming language design. Haskell
> provides higher-order functions, non-strict semantics, static polymorphic
> typing, user-defined algebraic datatypes, pattern-matching, list
> comprehensions, a module system, a monadic I/O system, and a rich set of
> primitive datatypes, including lists, arrays, arbitrary and fixed precision
> integers, and floating-point numbers.[^jones]

[^jones]: Jones, Simon P., ed. "The Haskell 98 Report." Haskell.org. Dec. 2002.
    Accessed 5 Dec. 2008 <http://www.haskell.org/onlinereport/literate.html>.

Functional programming is hard to understand at first, much like that smart kid
with no people skills. But once you get to know him, you rely on him and can
count on him to be reliable. He won’t make a lot of errors, and his performance
is at the top of his class.

## Thought I: Declarative vs. Imperative

The majority of common programming languages, including C/C++ and Java, are
_imperative_ languages. In imperative languages, the computer receives
instructions from a series of commands executed sequentially. Although there are
control structures, like branches and loops, and although there are functions,
usually the main routine of  an imperative program has commands to be executed
sequentially.

In contrast, Haskell is a _declarative_ language. At the base level, this means
that the functions are defined by a goal, rather than a state. More
specifically, Haskell is a functional programming language. This means that a
program is composed entirely of functions. In fact, even the program is a
function whose input is the the program input, and the output is the program
output. The main function simply calls other functions which in turn call still
more functions, until the bottom functions return a primitive value.[^hughes]

[^hughes]: Hughes, John. _Why Functional Programming Matters._ Tech.No. Computer
    Science, Chalmers University of Technology. WebCT. 1 Sept. 2008. University
    of Texas at Arlington. 16 Nov. 2008 <http://webct.uta.edu>.

In this first thought, I will discuss the main differences between functional
and imperative languages.


### Variables vs. Identifiers

In standard imperative programming, we use variables, and we use them like
crazy. We use them to keep counts of occurrences of actions, iterate loops,
store values returned by functions, store results of mathematical calculations,
or just about anything else possible. In a functional language, this is not the
case.

However, we do have identifiers. Identifiers stand in the place of a value
during a function’s run. For example, if we call a function `f(10)`, we should see
a definition that looks something like this:


~~~haskell
f x =
    if x <= 0
      then 0
    else 1
~~~


Here you can see that Haskell uses something quite similar to a variable, in
this case it is called `x`. Rather than variables, these are called
"identifiers." An identifier is variable in the sense that it represents a
value, but differs in the sense that it is not programmatically created and
changed[^finkel]. For one thing, there is no such thing as an assignment
statement in a functional programming language. The identifier `x` here
represents the value passed to the function. Once it is here, it cannot be
modified. We also cannot create new variables within this function. That is, we
cannot arbitrarily set a value `y` within the above function `f`. For example, in
an imperative language the following code introduces a new variable `y` within
the function:


~~~c
function f (int x) {
   int y;
   if( x<= 0 ) y = 0;
    else y = 1;
   return y;
}
~~~

There is no equivalent to the creation of the above variable `y` in functional programming.

[^finkel]: Finkel, Raphael A. _Advanced Programming Language Design._ Ed. Leda
    Ortega and Carter Shanklin. Boston: Benjamin-Cummings Company, 1995.

### Iteration vs. Recursion

One of the great things we all love about imperative languages is the
ability to use a loop. Whether you need to do something 100 times over, or
you want to keep looping through some code, perhaps with user interaction
until a flag is set, or you need to iterate through the elements of an
array, the way to do it is a loop. For example, if you want to go through
an array and sum up the elements, you would could do something like this:

~~~c
function sumArray( int itemArray[] ) {
   int sum = 0;
   foreach( itemArray as item ) {
     sum += item;
   }
}
~~~


As with variables, there is no equivalent of a loop control structure in
functional programming. Instead, the programmer uses recursion. A similar
function in functional programming would be written like this:

~~~haskell
sum (num:list) = num + sum(list)
sum nil = 0
~~~


As you can see here, since "recursive functions invoke themselves,
allowing an operation to be performed over and over"[^fp-wikipedia], `sum`
takes the head of the list, `num`, and adds it to what gets returned from
`sum(list)`, (the rest of the list), and will keep doing it until `list` is
`nil`. At that point, you can see from the second definition that sum will
return `0` and everything can be evaluated back up to the top call to get
the final sum. The code for this implementation in an imperative language
might look like this:

[^fp-wikipedia]: "Functional programming." Wikipedia. Accessed 5 Dec. 2008
    <http://en.wikipedia.org/wiki/functional_programming>.

~~~c
function sumArray( itemArray, sum ) {
   if( isset(itemArray[sum]) )
     sum += itemArray[sum];
   else
     sum = 0;
}
~~~

You can see that functional programming is designed to handle recursion
simply and elegantly.

### Function Side Effects

In functional languages, function side effects do not exist. That is, any call
to a function with the given arguments will always return the same result. In
imperative languages, any time a function is passed by reference, modifies
global variables, or outputs to the screen or a file, it is called a side
effect. For example, a function such as:

~~~c
function f(&x) {
   print x++;
}
~~~

has side effects. the first side effect is that it writes x to a display or to a
file. The second side effect is that since x is being passed by reference and is
modified, the value of x in the calling function has been changed. However, in
functional programming, we have no need to worry about side effects: "Because no
variables are used, it is easy to define the effects (that is, the semantics) of
a program."[^finkel]

## Thought II: Haskell's Heroic Accopmlishments

Haskell has made some major contributions to not only functional programming
languages, but also programming languages in general. This thought serves to
describe just a few of them.

### Syntax vs. Semantics

Although the phrase "syntax is not important" was the catch-phrase of the 1980s,
Haskell stood up in the face of adversity and proved that structuring the syntax
would allow more freedom for the programmer.[^hudak] Haskell contributed to
syntax in the following areas:

[^hudak]: Hudak, Paul, John Hughes, Simon P. Jones, and Philip Wadler. A History
    of Haskell: Being Lazy with Class. Tech.No. WebCT. 1 Sept. 2008. University
    of Texas at Arlington. 5 Dec. 2008 <http://webct.uta.edu>.


**Currying** is a way for functions to be defined in such a way that the result of a
function may be passed as the argument to another function within the same
call.  Many languages today, including C++ and Java, allow you to use the
result of a function as an argument to another. 

**No prefix operators** except for negation. "The dearth of prefix operators
makes it easier for readers to parse expressions"[^hudak]

**Keywords** were kept to a minimum to allow the programmer as much flexibility
as possible. Haskell has 21 reserved keywords. For example. Java has 50
reserved keywords and C++ has 63 (Hudak, 12). 

**Commenting style** was set to three distinct styles. The first is a line
comment where the line starts with `--` and ends with a new line. The second is
a block comment, starting with `{-` and ending with `-}`. The third is called a
"literate comment." A literate comment is more of a system, originating with
Donald Knuth, where a special mark is placed before a line of code rather than
a comment. In Haskell’s case, this is a `>`.[^jones] This allows for detailed
documentation inside the code for the file without having to comment out each
individual line or block. The following is an example showing the three kinds
of comments standard to Haskell.

Line and Block Comments:

~~~haskell
-- this is a line comment
f x =
 if x <= 0
  then 0
 else 1

{- this is
    a block comment -}
~~~

Literate Comments:

~~~literate_haskell
This is a literate comment, where anything not preceded by a ‘>’ is considered
a comment. If the line starts with a ‘>’, then it is interpreted as code.  

> f x =  
>   if x <= 0
>     then 0
>   else 1

The above lines are interpreted as code.
~~~

## Thought III: Haskell in the Real World

More and more programmers are being drawn to Haskell each year, perhaps
exponentially, according to a survey done by Haskell. The figure to the right
shows the number of respondents who had learned Haskell by the year indicated.
Each year, the Haskell community is increasing by large numbers.[^hudak] The
following are just a couple examples of Haskell at work in the real world.

### In the Linux Community

Haskell seems to have a large response from within the Linux community. The
Linspire Linux core OS team chose Haskell for their preferred language for
systems programming (Hudak 43). An odd choice to think of at first, but it helps
to give legitimacy to Haskell.

In addition to Linspire, xmonad is "a dynamically tiling X11 window manager that
is written and configured in Haskell".[^xmonad] The reason they chose Haskell
as the language to build the window manager in is because it makes the program
stable. The fact that Haskell has no side effects virtually eliminates bugs if
the programming process was done correctly.

[^xmonad]: "That was easy. xmonad rocks!" Xmonad. Mar. 2008. 5 Dec. 2008
    <http://xmonad.org>.

### Using Software Written in Haskell

"One of the turning points in a language’s evolution is when people start to
learn it because of the applications that are written in it rather than because
they are interested in the language itself." One application, called
Darcs, is an example of such a program. Darcs is a revision-control system in
competition with programs like CVS and Subversion, but it it is written in
Haskell. Doing so allowed the program to be rewritten from C++ to Haskell in a
short amount of time and eliminating most of the bugs.

## Thought IV: Haskell in My Book

Rather than simply summarize my findings on Haskell, I thought I would throw a
little of my opinion in. I hope it is worth all two cents.

### The Bad

Although it is nice to see Haskell gaining traction, I don’t think we will ever
see it–or any other functional programming language–really take off. I have two
main reasons why I believe this:

First, I feel that the syntax for functional programming is a lot for a person
to comprehend. I don’t think that the natural way to consider a problem is to
use recursion. If we need to add up all the elements in our list, we go down the
list in order and add each element to our sum and continue on down the list
until we’ve reached the bottom. We don’t split the list up into sub-lists until
we get one element at the bottom and add them up as we go back up the list.
That’s just not how our brain (or at least my brain) works.

Second, universities and schools are usually the places where a person learns
their first programming language. If the institution does not teach any type of
functional programming along the way, only the most dedicated students will
strive to comprehend it. The initial learning curve is so steep that very few
would want to make the first climb into learning the language.

### The Good

Functional programming is a fantastic way of doing things. In fact, I believe
for many applications, it is better than imperative/structured programming. It
lends itself to be bug-free and stable.

Haskell’s user base is indeed growing. A quick visit to
[irc.freenode.net][freenode][^freenode] showed that 273 people were chatting in
the `#java` chat room, while `#haskell` had 497 users chatting about Haskell and
asking questions.

[freenode]: https://www.freenode.net
[^freenode]: Freenode provides discussion facilities for the Free and Open
    Source Software communities, for not-for-profit organizations and for
    related communities and organizations. Freenode’s IRC servers peak at over
    50,000 concurrent users and is know among programmers as the best place to
    get help concerning issues with coding software. <https://www.freenode.net>

### The Could-Be-Even-Better

Haskell could not really be that much better. There are two things I can see
room for improvement in. First, a proven track record. Yes, Linspire, xmonad,
Darcs, and others are adding to the track record every day, but until there is a
substantial list of production software written in Haskell, we will still see
the language staying in the underground. Second, I’d like to see the user base
expand a little more. Although it is growing, there is really not a whole lot of
documentation or records of personal experience to be found.

## Conclusion

Haskell has a rich history over the past few years. Its syntax and definition
have been painstakingly discussed and delivered by numerous councils on various
topics and occasions. It has defined many things and set standards for
functional programming as well as imperative programming. Haskell is beginning
to be used in more applications than were traditionally thought possible for
functional programming languages, and several widely-used products have been
developed using Haskell. We will start to see more programs in the future, but
it will probably not ever become one of the legendary languages like C/C++ or
Java.
