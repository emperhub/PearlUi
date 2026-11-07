# PearlUI documentation website

The static documentation site is built from the real API, defaults, guides and
bundled Lucide catalog. It has 26 guide pages, searchable public API, per-page
outlines, copyable Luau examples, light/dark mode and a mobile navigation drawer.
The introduction's window preview is an illustration, not a Roblox runtime.

From the repository root:

```sh
python tools/build_docs_site.py
python -m http.server 4173 --directory website/dist
```

Open http://localhost:4173/. Hash routes work under either a domain root or a
GitHub Pages subdirectory without server rewrites. All scripts, Markdown parser,
icons and license notices are included in the output; there is no CDN dependency.

Edit styles in styles.css and application behavior in app.js. Page definitions
and Luau examples live in tools/build_docs_site.py. Guides/API/default data are
generated into content.json; regenerate after updating their canonical sources.
The output folder website/dist is ignored. Deploy that folder to a static host.

```sh
python tools/build_docs_site.py --check
python tools/check_docs_site.py --compiler /path/to/luau-compile
```

The Marked parser is vendored at 18.1.3 with its license and archive SHA-256.
Only repository-authored Markdown is rendered; raw active HTML and unsafe link
protocols are removed before insertion. Search queries are always escaped.

The primary publication is https://emperhub.github.io/PearlUi/. The Pages workflow
builds, checks and publishes website/dist on main updates. In repository settings,
select Pages → Source → GitHub Actions. No personal access token is needed.

The original Sites checkout separately keeps its identity in .openai/hosting.json.
Its credentials never belong in this public repository.
