---
layout: blog
---
Brett asked [this question][q] on the Heroku mailing list:

  [q]: http://groups.google.com/group/heroku/t/1b012e631dd80e64

> I want to let users purchase custom domain names to access my app on Heroku.
When the purchase transaction takes place, I'd like to add the custom domain to
my app in real time.  I thought of using the Heroku gem/command line tool from
within the app, analagous to the command-line expression: `heroku domains:add
www.example.com`. Is this possible?

It really got me thinking about exploring all that the Heroku API has to offer.

I thought I remembered seeing someone using the Heroku gem inside their code
before, but I couldn't remember where, and I couldn't seem to find any examples
in the [Heroku docs][docs]. Good! Time to get my hands dirty with some raw
source code.

  [docs]: http://docs.heroku.com

I opened up the [Heroku client source code][client.rb] and it's actually designed
to be used inside your code. How about that. The first few lines after all the
requires describe perfectly how to use it:

    # A Ruby class to call the Heroku REST API.  You might use this if you want to
    # manage your Heroku apps from within a Ruby program, such as Capistrano.
    #
    # Example:
    #
    #   require 'heroku'
    #   heroku = Heroku::Client.new('me@example.com', 'mypass')
    #   heroku.create('myapp')

 [client.rb]: http://github.com/heroku/heroku/blob/master/lib/heroku/client.rb

As you scroll down through the functions, you find that you can do anything in
your source code that you could do on the command line. To answer the original
question, if you wanted to use this command-line task:

    heroku domains:add www.example.com

You would simply put these lines in your source code:

    require 'heroku'
    heroku = Heroku::Client.new('me@example.com','mypass')
    heroku.add_domain('myapp','www.example.com')

The add_domain function is found on [line #120 of client.rb][add_domain].

  [add_domain]: http://github.com/heroku/heroku/blob/master/lib/heroku/client.rb#L120

**UPDATE:** Someone replied to the thread, pointing out that you should keep
things such as your Heroku credentials out of your code and in an environment
variable. Heroku already stores your app name by default in `ENV["APP_NAME"]`.
So, to make the above code a little DRYer and safe to distribute. At the
terminal:

    heroku config:add HEROKU_EMAIL=me@example.com HEROKU_PASS=mypass

And then in our code:

    require 'heroku'
    heroku = Heroku::Client.new(ENV["HEROKU_EMAIL"],ENV["HEROKU_PASS"])
    heroku.add_domain(ENV["APP_NAME"], 'www.example.com')

Now we won't be distributing our Heroku credentials with our code.