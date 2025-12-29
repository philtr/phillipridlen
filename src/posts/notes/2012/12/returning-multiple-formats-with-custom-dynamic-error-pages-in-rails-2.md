---
layout: post
type: note
title: Returning Multiple Formats with Rails Dynamic Error Pages
excerpt: |
  Yesterday my coworker Eric asked me to build out some dynamic error pages for the upcoming
  version of one of our apps. He suggested a certain pattern that we used in a previous
  application. Being the adventurous soul that I am, I wanted to make sure his way was the best
  way.
category: Programming
tags:
  - Ruby
  - Ruby on Rails
  - JSON
  - Errors
ghi: https://github.com/philtr/phillipridlen/issues/7
styles:
  - code
date: '2012-12-13T09:00:00-06:00'
---

Yesterday my coworker [Eric][eh] asked me to build out some dynamic error pages for the upcoming
version of one of our apps. He suggested a certain pattern that we used in a previous application.
Being the adventurous soul that I am, I wanted to make sure his way was the _best_ way. After some
deep <s>soul</s> google searching, I found out that Eric's method was considered best practice. It's
described in some detail on [Jos&eacute; Valim's blog post][hidden-rails-features], but I'll break
it down for you here:

[eh]: http://erichurst.com
[hidden-rails-features]: http://blog.plataformatec.com.br/2012/01/my-five-favorite-hidden-features-in-rails-3-2/

First, we need a controller for our error pages. Start out with something simple, like this:

~~~ ruby
# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  layout 'error' # only if you want a separate layout for your errors

  # 404 Not Found
  def not_found
  end

  # 422 Unprocessable Entity
  def unprocessable
  end

  # 500 Internal Server Error
  def internal_server
  end
end
~~~

Now let's add some routes:

~~~ ruby
YourApp::Application.routes.draw do
  match '/404', to: 'errors#not_found'
  match '/422', to: 'errors#unprocessable'
  match '/500', to: 'errors#internal_server'
end
~~~

With Rails 3.2, error pages have been extracted to a [Rack Middleware][mw].  Fortunately for us, so
are the application routes. We can to tell rails to use our routes app for the error pages in
`config/application.rb`:

[mw]: http://stackoverflow.com/a/2257031/383950

~~~ ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # ...

    config.exceptions_app = self.routes
  end
end
~~~

And that's it! Add some page templates in `app/views/errors/` and you should be good to go.

To test it, we need to turn off the development mode error pages. Set `consider_all_requests_local`
to false in `config/environments/development.rb`:

~~~ ruby
# config/environments/development.rb
YourApp::Application.configure do
  # ...

  config.consider_all_requests_local = false

  # ...
 end
~~~

You'll want to set that back to true before committing your code, or else you won't receive any
helpful feedback while developing your application.

All of the above steps were fairly simple, but figuring out how to determine which format to return
is a little complex.  `env['REQUEST_PATH']` contains the error path (e.g. "/404") and no format
information is getting passed to the errors controller, so the standard Rails `respond_to` stuff is
not going to work here. We can grab the original request path via `env['ORIGINAL_FULLPATH']`. I
added a few private methods to errors controller to help out. The first two help me figure out what
format the request came as. I want to return a JSON response if the request starts with '/api' or
ends in '.json'. The third will render our template in the format we want.

~~~ ruby
class ErrorsController
  private

  def api_request?
    env['ORIGINAL_FULLPATH'] =~ /^\/api/
  end

  def json_request?
    env['ORIGINAL_FULLPATH'] =~ /\.json$/
  end

  def render_error(error)
    if api_request? or json_request?
      render "#{error}.json.jbuilder"
    else
      render "#{error}.html.haml"
    end
  end
end
~~~

Now we just need to update the actions in our controller:

~~~ ruby
class ErrorsController
  def not_found
    render_error "not_found"
  end

  def unprocessable
    render_error "unprocessable"
  end

  def internal_server
    render_error "internal_server"
  end
end
~~~

And we're done! Make sure you add your json templates to `app/views/errors`.

~~~ bash
$ curl http://localhost:3000/api/v1/nothing-here
{ error: "not_found" }
$ curl http://localhost:3000/nothing-here.json
{ error: "not_found" }
$ curl http://localhost:3000/nothing-here
<h1>404 Not Found</h1>
~~~
