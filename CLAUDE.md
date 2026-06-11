# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Flutter app that browses [xkcd](https://xkcd.com) comics. Single-screen UI that fetches comic metadata from xkcd's JSON API and displays the image with navigation. Targets all Flutter platforms (Android, iOS, web, macOS, Linux, Windows); Dart SDK `>=3.3.0 <4.0.0`.

## Commands

```bash
flutter pub get                 # install dependencies (after editing pubspec.yaml)
flutter run                     # run on the default/connected device
flutter run -d chrome           # run in browser; also: macos, android, ios, linux, windows
flutter analyze                 # lint / static analysis (uses flutter_lints via analysis_options.yaml)
flutter test                    # run all tests
flutter test test/widget_test.dart --name "smoke test"   # run a single test by name
flutter build apk               # release build (apk | ios | web | macos | linux | windows)
```

## Architecture

Three source files in `lib/`, layered API client → UI:

- **`lib/networking.dart`** — `NetworkHelper` wraps a single `http.get` + `jsonDecode`. Returns decoded JSON on HTTP 200, otherwise returns `null` (prints the status code). All callers must null-check.
- **`lib/xkcd.dart`** — `Xkcd` is the API client. Comic metadata lives at `https://xkcd.com/<num>/info.0.json`; the latest is at `https://xkcd.com/info.0.json`. Methods: `getLatest`, `getRandom` (picks `Random().nextInt(maxNum)`), `getByNum`, `getMaxNum`, and `getByDate` (binary search over comic numbers by date, since the API has no date lookup).
- **`lib/main.dart`** — `MyHomePage` is a single `StatefulWidget` holding all comic state as loose `var` fields (`xkNumber`, `xkcdImage`, `xkAlt`, etc.) and rebuilding via `setState`. There is no state-management library or model class — JSON map fields are read directly into widget state. The AppBar title shows the comic's alt text; actions are copy-link, open on explainxkcd.com (`url_launcher`), and search-by-date.

### Key invariants

- **Comic #404 does not exist** — every navigation path special-cases it (`getByNum`, `getPrevious`, `getNext`, and the binary search in `getByDate` all skip 404). Preserve this when touching navigation.
- Comic numbering is 1-based; `getPrevious`/`getNext` clamp to `[1, xkMaxNum]`.
- `imageLoading` gates whether comic UI/actions render; `isSearching` gates the date-search spinner.

## Notes

- `test/widget_test.dart` is the **stale default Flutter counter test** and does not match this app — it will fail if run. Replace it with real tests rather than treating it as a working baseline.
- `flutter_lints` is active but no custom rules are configured. Note that `networking.dart` uses `print`, which the default lint set flags (`avoid_print`).
- Active task lists live in `ToDo_2026-02-27.md` and `ClaudeToDo.md`.
