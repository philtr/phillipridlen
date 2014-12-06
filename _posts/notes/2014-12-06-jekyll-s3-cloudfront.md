---
layout: post
title: "Jekyll, S3, and CloudFront"
---

GitHub pages is awesome. Like, _really_ awesome. But I wanted to try something new that would give
me a little more flexibility (e.g. the ability to use Jekyll plugins). So I started looking around
for the best way to deploy my static site to S3.

Boy, did I ever tumble down a rabbit hole. It seems like everyone's got their own idea of [how
it](http://vvv.tobiassjosten.net/development/jekyll-blog-on-amazon-s3-and-cloudfront/) [shoud
work](http://brettterpstra.com/2014/02/21/a-jekyll-cdn-with-cloudfront/), each with their custom
one-off scripts that I would hate to debug, and not fully supporting what I was trying to
accomplish. That's when I remembered seeing [jekyll-s3](https://github.com/laurilehmijoki/jekyll-s3)
at some point in history, so I thought I would at least check it out to see if development was still
active. Well, as it turns out, development has indeed continued, just on a different project called
[s3_website](https://github.com/laurilehmijoki/s3_website). `s3_website` can deploy any set of files
to Amazon S3, but Jekyll and Nanoc are supported right out of the box with no additional
configuration.

`s3_website` is a mature and powerful tool. Not only does it deploy your site to S3, but it has a
host of other features. If you set up CloudFront to distribute your website from S3, `s3_website`
will handle all the cache invalidation commands so you don't have to worry about it. It also
supports [dotenv](https://github.com/bkeepers/dotenv) out of the box, so you can commit your
configuration file without sensitive access keys.

The only downside is now I have to be at my computer to make a change to my website, but let's be
honest here&mdash;how often is that situation going to come up? Considering my last post was written
nearly two years ago, not often.

