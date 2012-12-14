---

layout: post
type: blog

title: "Modular Routing for Rails"
date: 2012-12-13

---

{% highlight ruby %}
# app/routers/api_router.rb
module ApiRouter
  CURRENT_API_VERSION = 1

  include ApiRouter::V1

  def current_api_version
    CURRENT_API_VERSION
  end

  def current_api_version_routes
    send :"api_version_#{current_api_version}_routes"
  end

  def routes_for_api_version(version)
    send :"api_version_#{version}_routes"
  end
end
{% endhighlight %}

{% highlight ruby %}
# app/routers/api_router/v1.rb
module ApiRouter::V1
  def api_version_1_routes
    lambda do
      # Gets called in the context of 'Some::Application.routes.draw'
      match 'hello' => 'things#index'
    end
  end
end
{% endhighlight %}

{% highlight ruby %}
# config/routes.rb
include ApiRouter

Some::Application.routes.draw do

  # Api Routes
  namespace :api do
    namespace :v1, &routes_for_api_version(1)
    # namespace :v2, &routes_for_api_version(2)
    # etc
  end

  # Use latest API routes for latest web
  scope :module => "api/v#{current_api_version}", &current_api_version_routes

  # Web-Only Routes
  #
  root :to => 'pages#index'

end
{% endhighlight %}

