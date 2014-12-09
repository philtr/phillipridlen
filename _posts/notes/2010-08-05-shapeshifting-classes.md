---
layout: post
type: note

title: "Shapeshifting &ldquo;Classes&rdquo;"
description:

category: "Programming"
tags:
  - ruby
  - object-oriented programming
  - constants
---
I've been using Ruby full-time+ for the last few weeks, working on projects at
work and then personal projects when I get home. There are a few things I've
learned about Ruby that surprised me. Most of these were discovered when, going
out on a limb, I tried something completely random to see if it worked--and it
did!

On one of my projects, when initializing the application,  I needed to be able
to choose one class (we'll call it `FujiApple`) if certain variable was set, and a different
class (call it `Gala`) if it was not. So I tried the following:

{% highlight ruby %}
if @certain_var.nil?
  AppleType = GalaApple
else
  AppleType = FujiApple
end
{% endhighlight %}

Now, keep in mind, `AppleType` is not a class that I have defined anywhere in my
code, yet I could use it just the same as the class that I set it to!

**What's really going on here?**

It took me a while to realize that I'm not actually creating a new class here
(and hence the reason I put "classes" in quotes). What's actually happening
is that `AppleType` is just a plain old constant. However, because that constant
is pointing to a class, you can use the same as if its own class.

If my `FujiApple` class looks like this:

{% highlight ruby %}
class FujiApple
  def eat
    "NOM NOM NOM"
  end
end
{% endhighlight %}

I can do this:

    > AppleType = FujiAple
      => FujiApple
    > myApple = AppleType.new
      => #<FujiApple:0x1011b31c0>
    > myApple.eat
      => "NOM NOM NOM"

**Should I use it?**

I'm not *quite* sure how good this practice actually is, because if we need to
change the `AppleType` somewhere in the middle of the application run, then we
are changing a constant, which is a no-no. However, if used properly, and only
set during the initialization phase of the app (i.e. once), I believe it is a
handy shortcut to having to check for the existence of that variable every time
you want to use the class. Feel free to correct me on this. There is probably a
better way to do it, such as using inheritance, but I found it fascinating that
a solution like this would even work.


