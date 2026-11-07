---
name: pearl-ui
description: "Build, integrate, configure, or debug the PearlUI Roblox Luau UI library, its macOS-style components, per-game configs, persistence adapters and interactive showcase. Use for PearlUI work, not unrelated Roblox gameplay or other UI libraries."
---

# PearlUI

Use the existing PearlUI implementation rather than inventing a different UI
framework. The public repository is https://github.com/emperhub/PearlUi.
The library is client-side Luau; server persistence and optional local-file
storage are separate adapters. This skill describes version 0.8.0. In a newer
checkout, inspect the implementation and current docs before relying on a
version-specific detail.

## Choose the relevant reference

- Adding controls or wiring callbacks: [API contract](references/api.md).
- Choosing initial values: [default values](references/defaults.md) and the
  machine-readable [defaults catalog](references/defaults.json).
- Integrating into Studio, a local preview or an existing project:
  [integration](references/integration.md).
- Configs, JSON transfers, auto-load or durable storage:
  [configs](references/configs.md) and [persistence](references/persistence.md).
- Fixing rendering, event, lifecycle or layout bugs:
  [architecture and regressions](references/architecture.md).
- Testing or preparing deliverables: [validation](references/validation.md).
- Finding an interactive example for any public method:
  [showcase guide](references/showcase.md) and [API locations](references/showcase-api.json).

Read only the references relevant to the current task. They are bundled so
this skill remains useful when installed without a full repository checkout.

## Working conventions

1. Locate the PearlUI checkout or obtain the exact module version the caller
   uses. Keep the current theme, config scope, custom accent, names and saved
   profiles when updating an existing UI.
2. Assign explicit, stable IDs to persisted controls and sections. Labels are
   presentation; do not use label changes as a persistence-key migration.
   Set `Persist = false` on inspectors, config pickers and temporary examples.
3. `PearlUI.new()` defaults to Light and a `global` scope. The supplied demo
   intentionally uses `game_<game.GameId>` for per-game data. Forest is an
   available dark-green theme, not the library's implicit default. Respect a
   caller's explicitly chosen scope/theme instead of silently changing it.
4. Construct the full UI, call `CaptureDefaults()`, then configure persistence.
   Persisted startup state or auto-load may override these initial values.
   A named config is updated by Save changes; auto-save preserves the current
   working setup and list without silently replacing that named snapshot.
5. Use public methods for product integrations. Underscore methods and private
   instance fields are implementation details; use them only when maintaining
   the library/showcase itself and inspect their callers first.
6. Keep existing local user settings outside source control. Code, examples,
   documented defaults and schema fixtures belong in the repo; actual account
   config JSON, backups, credentials and local review captures do not.
7. When modifying source, run `python tools/build.py` to refresh dist artifacts.
   For API/default changes also run `python tools/sync_skill.py` and
   `python tools/validate_metadata.py`. Do not hand-edit generated API/default
   reference copies to hide a mismatch.

## Important behavior

- Control callbacks receive values; ColorPicker callbacks receive Color3 and
  alpha, while serialization uses a JSON-safe HEX/alpha object. `Set(v, true)`
  is silent. `SetDisabled` blocks UI input, not programmatic setters.
- Dropdown values must exist in a nonempty unique string list. Multi-selection
  is an array in option order. Invalid configs are validated before applying.
- `SetAccent(color)` selects a custom override. `ResetAccent()` returns to the
  current theme and follows later theme changes. Preserve AccentMode when
  importing/exporting; old profiles without it keep legacy color behavior.
- Use `RequestReset` for a user-facing reset. Direct `Reset` is for deliberate
  code-driven application. Reset does not delete named configs.
- Opening a saved-config entry only selects it; Load applies it. Import saves
  a copy without applying it. Delete/overwrite UI actions require their normal
  in-product confirmations; this is not an extra authorization requirement for
  ordinary reversible code edits.
- A persistence adapter's Save must return true after acknowledgement. An
  initial failed load blocks writes until recovery. Do not replace durable
  persistence with an in-memory table while claiming it survives sessions.
- The standalone preview can use optional file APIs; the core module has no
  executor dependency. Studio DataStore access requires the separate server
  integration in the caller's game. Do not contact an unrelated game's remotes.

## Validation and reporting

Use the narrowest meaningful validation for the change. Report what was
actually checked, the version/client used, and any material untested surface.
The 0.7.0 core baseline passed 424 checks; 0.8.0 added a separate 45-check
showcase validation. These historical counts are not proof a new change is
tested. Read [validation](references/validation.md) before running suites.

Publishing, creating repositories, sending messages and modifying a live
integration need authorization from the current task. This skill does not
grant those permissions or require repetitive confirmations when the caller
has already authorized them.
