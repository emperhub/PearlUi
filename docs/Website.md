# Documentation website

Read the [online PearlUI documentation](https://pearlui-documentation.znithexx.chatgpt.site).
It is public and requires no sign-in. Library behavior remains version 1.0.2;
this addition changes documentation and CI only.

The website includes 26 pages, all 81 public APIs and 2,029 Lucide icons with
301 runtime aliases. Menus, full-text/API search, per-page outlines, copy buttons,
theme selection and the mobile drawer run locally in the browser.

Source is in website/. Page definitions and examples are in
tools/build_docs_site.py; API/default/guide content comes from the canonical
repository files. After changing them, run:

```sh
python tools/build_docs_site.py
python tools/check_docs_site.py --compiler /path/to/luau-compile
```

Commit regenerated website/content.json. CI checks it against the canonical
content and validates asset coverage and browser-script syntax. The build output
website/dist is ignored and can be uploaded to any static host. Hash routing also
works on GitHub Pages subdirectories without rewrites. The Sites-hosted checkout
has its own persisted .openai/hosting.json; keep its credentials out of source.

The initial website validation compiled 35 unique Luau examples and manually
checked desktop/narrow browser layouts, search-to-API navigation, copy feedback,
API filtering, icon filtering/copy and theme switching. These are website checks;
they do not constitute a fresh Roblox runtime audit. See
[WebsiteValidation.json](../tests/WebsiteValidation.json).
