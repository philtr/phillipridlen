---
layout: post
type: note

title: "Adam Asks: Parity, Blocks, and Enumerators. Oh My!"

category: Programming
tags:
  - Array
  - Beginner
  - Block
  - Enumerable
  - Enumerator
  - Parity
  - Ruby
---

> Can you check this over for me?
>
> Method that takes an array as argument, counts and displays the odds and evens from the array.
>
> It works as expected - I'm just looking for best practices

{% highlight ruby %}
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
{% endhighlight %}

Here’s how I would write it:

{% highlight ruby %}
def parity_counts(numbers)
  evens = numbers.select { |number| number.even? }
  odds  = numbers - evens

  puts "There are #{evens.size} even numbers and #{odds.size} " +
       "odd numbers in this array."
  puts "Evens: #{evens}"
  puts "Odds:  #{odds}"
end
{% endhighlight %}

- An array knows its size, so there is no need to keep track of it separately

- Integer has handy even? and odd? functions that return true or false. Under
  the hood, they’re doing exactly what you did. n % 2 == 0
- Reducing if/else branches and loops helps the reader understand what is
  happening
- Yours might have better performance, especially as input size approaches
  infinity
- Your print statements are fine, but you’ll see people using puts with string
  interpolation (#{}) when they want to print as string ending in a new line.
- In a real-world application, I would probably not put the screen output as
  part of the computation logic. You’d probably want to return a hash or other
  data structure and put the presentation logic somewhere else.

There is more than one way to skin a cat. Here’s an alternate implementation:

{% highlight ruby %}
def parity_counts(ns)
  ns.reduce([[],[]]){|(e,o),n|n.odd? ? o<<n : e<<n;[e,o]}
end
{% endhighlight %}

This will return an array where the first element is an array of even numbers,
and the second is an array of odd numbers. But there is very little about this
solution that is best practice. Clarity should be preferred to brevity:

- Variable names should reflect what is stored in them. Single letter names and
  even some abbreviations don’t make it immediately clear as to what it is to be
  used for.
- reduce is not a concept that is easy to grasp. I use it sparingly when it
  really makes the most sense, rather than just because it makes me feel smart.
- When you have more than one statement inside an iterator, it’s good style to
  use do/end instead of curly braces, and break up the statement into multiple
  lines. There are varying schools of thought on this:
  - Some people use curly braces when they are using the value returned from the
    iterator (e.g. give me the parent contact email for each student), and
    do/end when they are mutating state (e.g. take this list of students and
      calculate their grade)
  - Other people say to always use curly braces for single line and use do/end
    for multiple lines. I follow this pattern, I feel like it looks better.

So using reduce, I would write it this way:

{% highlight ruby %}
def parity_counts(numbers)
  numbers.reduce([[], []]) do |(evens, odds), number|
    number.odd? ? odds << number : evens << number
    [evens, odds]
  end
end
{% endhighlight %}

The `[[], []]` sets up the data structure that we are going to pass to the first
iteration to store the values in. Reduce takes the return value of the block and
passes as the first argument to the next iteration. By wrapping the argument in
parens we can “unwrap” the array into separate arguments. It’s kind of a
confusing concept to wrap your mind around. If you’re curious about this, I
could explain it much better with a whiteboard than I can with words.

I get a little excited about this stuff. Can you tell? :)
