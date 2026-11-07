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

## Current 1.0.2 rerun audit

The replacement patch passed 379 assertions across eight suites: Rerun, Runtime,
Audit, Settings, Configs, Release, Close and Showcase. A separately evaluated
module retired the prior owner, flushed mock storage and restored values in the
new instance. Concurrent replacement and the 1.0.1 legacy upgrade were checked.
The real remote example was evaluated three times: one main window and one dock
remained, with both old owners and their listeners retired. See
[RerunValidation.json](https://github.com/emperhub/PearlUi/blob/main/tests/RerunValidation.json) for provenance and limits.
Fixtures intentionally comparing multiple same-name windows opt out with
ReplaceExisting=false. Do not opt out in ordinary rerun tests.

## Previous 1.0.1 close-button audit

The close-button patch passed 108 assertions: Close 20, Settings 38 and Runtime 50.
Red confirms complete teardown; Cancel retains the UI and yellow only minimizes.
Desktop and touch hit targets share one action. See
[CloseValidation.json](https://github.com/emperhub/PearlUi/blob/main/tests/CloseValidation.json) for scope and provenance.
The full 1.0.0 audit below is historical for this patch, not a fresh full rerun.

## Previous 1.0.0 evidence

The release audit passed 587 assertions across 16 suites plus the separate Icons
construction suite (2,029 icons / 301 runtime aliases). See
[ReleaseValidation.json](https://github.com/emperhub/PearlUi/blob/main/tests/ReleaseValidation.json) for exact commit provenance.
After the final native color-inset correction, Features, FeatureMotion and Release
were rerun successfully; unrelated suites retain the preceding full-run results.
Native mouse checks confirmed color changes, Done, dropdown page navigation and
selection from a rebuilt page. Compact viewport and gamepad cases are simulated.

Run `python tools/check.py --compiler <luau-compile> --verify-generated` for the
reproducible build, geometry, metadata and syntax checks. GitHub Actions runs the
same checks using a checksum-pinned official compiler on each push/PR. This CI
does not emulate a Roblox client. Physical touch/controller hardware, a published
DataStore and reopening XML in Studio remain unverified.

## Historical evidence boundaries

The 0.8.0 audit recorded 45 passing showcase checks; its historical
0.7.0 core baseline is 424 checks across 14 suites. The baseline was not rerun for
the demo-only update. These are separate results, not 469 fresh 0.8.0 checks.
Published DataStore, physical touch/gamepad and reopening generated XML in Studio
remain unverified in that report. Local source/build/default documentation checks
must be reported separately from runtime checks. Do not claim new runtime results
from historical counts, static metadata or successful compilation.
