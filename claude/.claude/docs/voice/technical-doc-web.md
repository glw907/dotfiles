# Register: SvelteKit/web developer documentation

The reader is a competent web developer adopting or operating the system, who has not read
the code. The persona is a maintainer pair-programming with the reader: second person,
example-first, direct, and occasionally wry. Show the thing, then narrate what happens when
the reader uses it.

Geoff picked this direction (2026-06-09, option B of the register election) over the
settled-fact register the early cairn docs drifted into. The exemplars below are the
empirical baseline, drawn from the SvelteKit and Svelte documentation (sveltejs/kit and
sveltejs/svelte, MIT). As new cairn docs are drafted in this register and Geoff edits them,
his edited passages replace the upstream ones, and the corpus rebuilds on those. Quotes are
lightly reflowed (one bullet list joined into prose) but otherwise as published.

One carve-out: upstream uses em dashes freely, and cairn docs stay under the docs-tier ban
(the authorship-plausibility rule). Imitate the voice, not the punctuation.

## Traits

- Second person throughout, and "we" when the writer and reader are doing something
  together ("we often need to get some data").
- Example-first. Show the code, then narrate the consequence in plain scenario terms: "If
  someone were to click the button, the browser would send the form data via POST request
  to the server."
- Reasons ride in parentheses mid-sentence ("because it uses private environment
  variables, for example, or accesses a database") instead of in separate justification
  sentences.
- Tradeoffs owned plainly and immediately: "The tradeoff is that the build process is more
  expensive."
- Concrete scenario painting over abstraction: name the marketing page, the admin section,
  the login form, not "various use cases".
- Light wit is allowed and rare. It seasons; it never performs.

## Exemplars

From the Svelte runes intro. Definition with a wink, then the differences as plain facts:

```
Runes are symbols that you use in .svelte and .svelte.js/.svelte.ts files to control the
Svelte compiler. If you think of Svelte as a language, runes are part of the syntax —
they are keywords.

They differ from normal JavaScript functions in important ways, however: You don't need
to import them — they are part of the language. They're not values — you can't assign
them to a variable or pass them as arguments to a function. Just like JavaScript
keywords, they are only valid in certain positions (the compiler will help you if you
put them in the wrong place).
```

From the form-actions page. Example-first, then the consequence narrated as a scenario:

```
To invoke this action from the /login page, just add a <form> — no JavaScript needed.
If someone were to click the button, the browser would send the form data via POST
request to the server, running the default action.

When using <form>, client-side JavaScript is optional, but you can easily progressively
enhance your form interactions with JavaScript to provide the best user experience.
```

From the loading-data page. "We" for the shared task, reasons in parentheses:

```
Before a +page.svelte component (and its containing +layout.svelte components) can be
rendered, we often need to get some data. This is done by defining load functions.

If your load function should always run on the server (because it uses private
environment variables, for example, or accesses a database) then it would go in a
+page.server.js instead.
```

From the hooks page. A mechanism explained in flowing prose with the practical payoff in a
parenthetical:

```
This function runs every time the SvelteKit server receives a request — whether that
happens while the app is running, or during prerendering — and determines the response.
It receives an event object representing the request and a function called resolve,
which renders the route and generates a Response. This allows you to modify response
headers or bodies, or bypass SvelteKit entirely (for implementing routes
programmatically, for example).
```

From the page-options intro. Concrete scenario painting addressed to you:

```
You can mix and match these options in different areas of your app. For example, you
could prerender your marketing page for maximum speed, server-render your dynamic pages
for SEO and accessibility and turn your admin section into an SPA by rendering it on the
client only.
```

From the glossary. A definition that owns its tradeoff in the next breath:

```
Prerendering means computing the contents of a page at build time and saving the HTML
for display. This approach has the same benefits as traditional server-rendered pages,
but avoids recomputing the page for each visitor and so scales nearly for free as the
number of visitors increases. The tradeoff is that the build process is more expensive
and prerendered content can only be updated by building and deploying a new version of
the application.
```

Geoff's calibration pick, the cairn save flow drafted in this register (the passage that
chose the direction):

```
When you hit Save, cairn doesn't write to a database. It commits your markdown straight
to the repo's main branch. The commit goes through a GitHub App, so you don't need a
GitHub account; you still show up as the author, and the bot does the signing. From
there your normal deploy takes over, the same as if you'd pushed from a terminal. If
someone else changed the file while you were editing, cairn refuses the save instead of
guessing how to merge. Reload, reapply your change, save again.
```

## Off-voice contrast

The same content in the register this file exists to prevent:

```
cairn-cms takes a unique approach to authentication. Rather than relying on heavyweight
third-party solutions, it features a streamlined magic-link flow designed with security
best practices in mind. This means you can rest assured that your editors enjoy a
seamless login experience while your content remains fully protected.
```
