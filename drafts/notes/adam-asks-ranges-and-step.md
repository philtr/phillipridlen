---
layout: post
type: note

title: "Adam Asks: Ranges and Step"

category: Programming
tags:
  - Array
  - Beginner
  - Enumerator
  - Enumerable
  - Range
  - Ruby
---

> Is there a more eloquent way to make this method?
>
> I want a method that takes 3 parameters (but has default settings) to make an
> array that holds essentially some user-defined skip-counted integers.
>
> I don't really know any best practices stuff and was hoping you could show me
> some.

{% highlight ruby %}
def counter(start = 1, to = 100, by = 1)
  while start <= to
    numbers ||= []
    numbers.push(start)
    start += by
  end

  return numbers
end
{% endhighlight %}

This should do it: 

{% highlight ruby %}
def counter(start = 1, to = 100, by = 1)
  (start..to).step(by).to_a
end
{% endhighlight %}

<http://ruby-doc.org/core-2.3.1/Range.html#method-i-step>

Ranges are really cool. Also make use of Ruby documentation for things like
Enumerable, Hash, Array, Integer, String, etc. There are some neat methods on
those that you wouldn't expect there to be.
