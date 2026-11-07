# Validation guide

## Local checks

Run from the repository root:

```text
python tools/build.py
python tools/sync_skill.py
python tools/validate_metadata.py
python skills/pearl-ui/scripts/inspect_project.py .
```

Build checks exact embedded-source roundtrips in generated XML. Metadata validation
checks all public API signatures/contracts, all theme roles and default constraints,
showcase coverage, copied skill references and portable links. It does not emulate
Roblox GUI behavior. Compile changed Luau using an available official luau-compile;
compiler success is syntax validation, not a Roblox runtime test.

## Runtime suites

Run test ModuleScripts on a disposable client UI with the same library version,
not a live window containing someone’s real configs. Most return a function taking
`PearlUI`: Runtime, Animation, Dock, Features, FeatureMotion, ColumnsProfile, Audit,
DetachedGeometry, NotificationDock, Themes, Settings and Configs. Each throws on
failure and returns results after cleanup. Read the suite body for its prerequisites.
FileStorage takes the file-adapter factory and provides fake storage. PersistenceServer
takes a build function that evaluates the server with mocked services; it does not
validate a published DataStore. Showcase takes `build` (fresh complete demo factory)
and the public method-name array from docs/API.json, exposing `_testBench` internally.

When a connected-client tool is available, list clients and select the intended
session afresh; never store client identifiers in source/skill. Load exact source
without altering newlines or escaping, check syntax/evaluation responses, run suites
against isolated test instances and destroy them. A disconnect ends that run; reconnect
and re-list before continuing. Do not touch an unrelated game's remotes or reset a
person's saved configs to make a test pass.

## Regression coverage to choose

- Controls/value validation/ID rollback: Runtime, Features, Audit.
- Layout, responsive columns, profile roundtrip: ColumnsProfile, DetachedGeometry.
- Overlapping motion/theme/opacity: Animation, FeatureMotion, NotificationDock, Themes.
- Dock position/stow/recovery: Dock and native viewport/input checks.
- Reset/config/storage: Settings, Configs, FileStorage, PersistenceServer as applicable.
- Showcase bindings and every API location: Showcase and metadata coverage.

Native visual checks should include both themes and custom accents, rapid tab/open/
close/detach/dock actions, popup clipping, scroll bounds, compact viewport, disabled
controls, preview toast and side-stowed dock recovery. Record what was actually tried.

## Evidence boundaries

tests/latest-results.json records 45 passing showcase checks for 0.8.0; its historical
0.7.0 core baseline is 424 checks across 14 suites. The baseline was not rerun for
the demo-only update. These are separate results, not 469 fresh 0.8.0 checks.
Published DataStore, physical touch/gamepad and reopening generated XML in Studio
remain unverified in that report. Local source/build/default documentation checks
must be reported separately from runtime checks. Do not claim new runtime results
from historical counts, static metadata or successful compilation.
