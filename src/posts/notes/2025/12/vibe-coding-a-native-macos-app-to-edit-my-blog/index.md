---
category: Programming
date: '2025-12-29T22:47:00-06:00'
draft: true
image: admin.mp4
layout: post
styles:
  - code
  - posts/image
tags:
  - admin
title: Vibe coding a native macOS app to edit my blog
type: note
---

I have an awesome new editor for my website. It’s a native macOS SwiftUI app
that I can boot up on my Mac and write and edit posts. I don’t know Swift. And I
don’t know the SwiftUI API. To me this is the perfect candidate for blind vibe
coding. It’s a totally offline, unsupported app that improves my quality of life
and inspires me to write, because it feels… well, it just feels _good_.

<video src="admin.mp4" controls autoplay loop muted playsinline></video>

<figcaption>Collapsible sidebar, date pickers, posts sorted by date and grouped
by month.</figcaption>

It’s not perfect. And I have lots of ideas for improvements. It will just keep
getting better and better. If you’re interested, you can look at the source [in
the `macos/BlogAdmin` folder of the repo for this
site](https://github.com/philtr/phillipridlen/tree/master/macos/BlogAdmin).

I’ve been using the OpenAI Codex CLI for my personal projects, and I find it
roughly equivalent in features and quality to Amazon’s Kiro CLI that is provided
to me at work, which uses the Anthropic models. I think I prefer Codex just a
hair; it does a better job understanding my poor job of explaining what I want
it to do, and asks more clarifying questions if my instructions are too vague.
