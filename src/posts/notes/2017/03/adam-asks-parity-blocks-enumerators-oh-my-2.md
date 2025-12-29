---
layout: post
type: note
title: 'Adam Asks: Parity, Blocks, and Enumerators. Oh My!'
modified: 2022-12-29
category: Programming
tags:
  - Array
  - Beginner
  - Block
  - Enumerable
  - Enumerator
  - Parity
  - Ruby
  - Reduce
styles:
  - code
date: '2017-03-10T09:00:00-06:00'
---

Adam is a friend of mine learning to program. Every once in a while, he'll send
me a bit of code to look over to learn how he might be able to do it better. The
latest one was an exercise involving splitting an array based on the parity of
the number, that is to say whether the number is even or odd.

> Can you check this over for me?
>
> Method that takes an array as argument, counts and displays the odds and evens
> from the array. It works as expected&mdash;I'm just looking for best
> practices.

Here is Adam's original code:

~~~ ruby
def numbereven(numarr)
  neven = 0
  nodd = 0
  narray = []
  narrayo = []

  numarr.each do |n|
    if n%2 == 0
      neven += 1
      narray.push(n)
    else
      nodd += 1
      narrayo.push(n)
    end
  end

  puts "There are #{neven} even numbers and #{nodd} odd numbers in this array."
  print "Evens: ", narray, "\n"
  print "Odds: ", narrayo, "\n"
end

my_array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100, 1001]

numbereven(my_array)
~~~

I may have scared him off with the sheer volume of my reply. I wrote a bit how I
would write it, another way to write it, and why I wouldn't write it that
way.


## How I Would Write It

~~~ ruby
def parity_counts(numbers)
  evens = numbers.select { |number| number.even? }
  odds  = numbers - evens

  puts "There are #{evens.size} even numbers and #{odds.size} " +
       "odd numbers in this array."
  puts "Evens: #{evens}"
  puts "Odds:  #{odds}"
end
~~~

- An array knows its size, so there is no need to keep track of it separately.
- Ruby integers have handy `even?` and `odd?` methods that return true or false.
  Under the hood, that method is doing exactly what you did: `n % 2 == 0`.[^rb-parity]
- Reducing `if`/`else` branches and loops helps the reader understand what is
  happening.
- Yours might have better performance, especially as input size approaches
  infinity.
- Your `print` statements ending in `\n` are fine, but you’ll more likely see
  people using `puts` with string interpolation (`#{}`) when they want to print
  a string ending in a new line.
- In a real-world application, I would probably not put the screen output as
  part of the computation logic. You’d probably want to return a hash or other
  data structure and put the presentation logic somewhere else.


## An Alternate Implementation

There is more than one way to skin a cat. Here’s an alternate implementation:

~~~ ruby
def parity_counts(ns)
  ns.reduce([[],[]]){|(e,o),n|n.odd? ? o<<n : e<<n;[e,o]}
end
~~~

This will return an array where the first element is an array of even numbers,
and the second is an array of odd numbers. But there is very little about this
solution that is best practice. Clarity should be preferred to brevity:

- Variable names should reflect what is stored in them. Single letter names and
  even some abbreviations don’t make it immediately clear as to what it is to be
  used for.
- `reduce` is a concept that is not easy to grasp. I use it sparingly when it
  really makes the most sense, rather than just because it makes me feel smart.
- When you have more than one statement inside an iterator, it’s good style to
  use `do`/`end` instead of curly braces, and break up the statement into multiple
  lines. There are varying schools of thought on this:
  - [Some people][avdi] use curly braces when they are using the value returned
    from the iterator (e.g. give me the parent contact email for each student),
    and `do`/`end` when they are mutating state (e.g. take this list of students
    and calculate each one's grade)
  - Other people say to always use curly braces for single line and use `do`/`end`
    for multiple lines. I follow this pattern; I think it looks nicer.

[avdi]: http://www.virtuouscode.com/2011/07/26/the-procedurefunction-block-convention-in-ruby/  

## A Better Version of the Alternate Implementation

So, given the concepts above, using `reduce`, I would write it this way:

~~~ ruby
def parity_counts(numbers)
  numbers.reduce([[], []]) do |(evens, odds), number|
    number.odd? ? odds << number : evens << number
    [evens, odds]
  end
end
~~~

The `[[], []]` sets up the data structure that we are going to pass to the first
iteration to store the values in. Reduce takes the return value of the block and
passes as the first argument to the next iteration. By putting parens around
`(even, odd)`, we can “unwrap” the array into separate arguments. It’s kind of a
confusing concept to wrap your mind around, but once you get it, it's incredibly
handy for writing iterators.

## Takeaways

In conclusion, a couple takeaways: First, Ruby has a huge standard library,
along with helper methods to do common things. It's usually a good idea to check
out the documentation for a given class to see if there is already a method to
do what you're trying to do (`even?` and `odd?` from above, for example).

Second, with Ruby, it's possible to write code that can almost be read as a
sentence. Variable names and function names following this pattern make your
code easier to understand and, in my opinion, much more fun to write.

## UPDATE: How about `Enumerable#partition?`

There's almost always a better way. Turns out, Ruby already has a method for
partitioning an enumerable. In this implementation, we ask each element in the
array if it is even. If so, it goes into the first partition. Otherwise, it
goes into the second.

~~~ ruby
numbers.partition(&:even?)
#=> [[2, 4, 6], [1, 3, 5]]
~~~

This is the shorthand syntax (using [`Symbol#to_proc`][to_proc]—a post for
another day, perhaps) that would be equivalent to writing

[to_proc]: https://blog.pjam.me/posts/ruby-symbol-to-proc-the-short-version/

~~~ ruby
numbers.partition {|number| number.even? }
~~~

So to put this back in to solve the original problem:

~~~ ruby
def parity_counts(numbers)
  evens, odds = numbers.partition(&:even?)

  puts "There are #{evens.size} even numbers and #{odds.size} " +
       "odd numbers in this array."
  puts "Evens: #{evens}"
  puts "Odds:  #{odds}"
end
~~~


[^rb-parity]: The source for this function is in C, but [here it is](https://github.com/ruby/ruby/blob/74cdd893eb102ba98e735f2a24c710e1928261a9/numeric.c#L3173-L3188) if you want to take a look at it.
