---
title: "Scripture \u2013 Simple Bible"
description: An offline Bible reader with 13 translations, two translation aids, tap-to-read footnotes, and word or verse highlights.
layout: bare
base_stylesheet: false
styles:
  - bible
favicon: /images/bible-icon.png
---

<header class="site-header page-width">
  <%= render "/bible/brand.html" %>
  <nav aria-label="Main navigation">
    <a href="#features">Features</a>
    <a href="#downloads">Downloads</a>
    <a href="#support">Support</a>
  </nav>
</header>

<main>
  <section class="hero page-width" aria-labelledby="hero-title">
    <div class="hero-copy">
      <p class="platform">For iPhone and iPad</p>
      <h1 id="hero-title">Read Scripture <em>offline.</em></h1>
      <p class="intro">Explore 13 Bible translations and two translation aids. Highlight words or verses and pick up where you left off.</p>
      <p class="availability">Coming soon.</p>
    </div>
    <figure class="reader-preview">
      <img src="/images/bible-reader.webp" width="720" height="1565"
           alt="Scripture on iPhone showing Genesis 1 with numbered footnotes">
    </figure>
  </section>

  <section class="features" id="features" aria-labelledby="features-title">
    <div class="page-width">
      <h2 id="features-title">Reading tools</h2>
      <div class="feature-grid">
        <div>
          <h3>Find any passage</h3>
          <p>Jump to a book and chapter. Switch between modern and historic English translations and two translation aids.</p>
        </div>
        <div>
          <h3>Mark what stands out</h3>
          <p>Highlight a word, a phrase, or a whole verse. Copy verses to share.</p>
        </div>
        <div>
          <h3>Read the footnotes</h3>
          <p>Tap a footnote number to read the note, then tap the return arrow to jump back to your place.</p>
        </div>
      </div>
    </div>
  </section>

  <div class="resources page-width">
    <section id="downloads" aria-labelledby="downloads-title">
      <h2 id="downloads-title">Scripture downloads</h2>
      <p>Get the same book files used in the app for the Literal Standard Version, Free Bible Version, Literal Text, and Simplified Text. The ZIP includes credits and source links.</p>
      <p><a class="download" href="/bible/downloads/sharealike-scripture.zip">Download the ShareAlike texts (ZIP)</a></p>
      <p class="license">You may copy, share, and adapt these files under the <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 license</a>. The same license applies to the files in the app's Translation Credits screen.</p>
    </section>
    <section id="support" aria-labelledby="support-title">
      <h2 id="support-title">Support</h2>
      <p>For questions, bug reports, or ideas, email me at <a href="mailto:phil@ptx.sh">phil@ptx.sh</a>.</p>
      <p><a href="/bible/privacy/">Privacy policy</a></p>
    </section>
  </div>
</main>

<footer class="site-footer page-width">
  <p>Made by <a href="/">Phillip Ridlen</a></p>
</footer>
