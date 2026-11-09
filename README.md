<p align="center">

![AI OVERENGINEERED](https://img.shields.io/badge/AI-OVERENGINEERED-blueviolet)
![CLAUDE CERTIFIED](https://img.shields.io/badge/CLAUDE-CERTIFIED-orange)
![CHATGPT POWERED](https://img.shields.io/badge/CHATGPT-POWERED-10a37f)
![HUMAN SUPERVISION: QUESTIONABLE](https://img.shields.io/badge/HUMAN_SUPERVISION-QUESTIONABLE-yellow)
![SERIOUSNESS LEVEL: 0%](https://img.shields.io/badge/SERIOUSNESS_LEVEL-0%25-red)

</p>

```text
  _____      _           _       ______             _
 / ____|    | |         | |     |  ____|           (_)
| |     ___ | |     __ _| |__   | |__   _ __   __ _ _ _ __   ___
| |    / _ \| |    / _` | '_ \  |  __| | '_ \ / _` | | '_ \ / _ \
| |___| (_) | |___| (_| | |_) | | |____| | | | (_| | | | | |  __/
 \_____\___/|______\__,_|_.__/  |______|_| |_|\__, |_|_| |_|\___|
                                               __/ |
                                              |___/
```

> ### THIS IS A JOKE PROJECT
> CoLab Engine is a meme fork of Psych Engine with a ridiculous amount of AI-generated comments.
> If you're genuinely getting offended over a silly Psych Engine fork with an absurd amount of AI-generated comments, please take a deep breath. It's not that serious.
> Full disclaimer [below](#2-important-disclaimer--this-is-a-joke-project).

## 1. Project Overview

**CoLab Engine** is a humorous modification of [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) (version 1.0.4), built as a collaboration between two AI assistants, Claude and ChatGPT, under the direction of a human who may or may not regret it.

The goal is to experiment with interface changes and a custom boot splash screen, while deliberately exaggerating how much AI was involved in the development. Internally it is still Psych Engine. Visually it presents itself as CoLab Engine.

It is not a rewrite. It is a small set of targeted changes on top of the existing Psych Engine source.

## 2. IMPORTANT DISCLAIMER — THIS IS A JOKE PROJECT

Please read this before opening an issue, a pull request, or a 14-tweet thread:

- CoLab Engine **is a joke project**.
- It does **not** aim to revolutionize game engine development.
- It does **not** try to prove that AI can replace developers.
- It is **not** a commercial product.
- It is **not** a serious statement about the future of programming.
- The absurd amount of comments, signatures and AI watermarks **is the joke**.
- It must **not** be read as a serious criticism of other developers or projects.

If you're genuinely getting offended over a silly Psych Engine fork with an absurd amount of AI-generated comments, please take a deep breath. It's not that serious.

The code does work as far as it has been checked (see [Known Limitations](#9-known-limitations) for exactly how far that is), but a working joke is still a joke.

It's just a joke. Please don't start a controversy over a meme engine.

## 3. Features

| Area | What changed |
| --- | --- |
| Boot | New `CustomSplashScreenState` that runs right before the original `TitleState`. Fully code-drawn animation: no video, no animated PNG, no spritesheet, no XML animation, no prerendered frames. |
| Main Menu | Main options aligned to the left. Options and Achievements stacked one under the other in the top right corner. Selection, controls, sounds and transitions are untouched. |
| Story Mode | Week list aligned toward the left. Difficulty selector moved into the top black bar, which is sized so the original difficulty graphics are never cropped or scaled. Track list stays in its original position. |
| Freeplay | Centered layout: song names and the score panel are centered, character icons are no longer drawn (they are still in the song metadata). |
| Master Editor Menu | Every option aligned to the left, no exceptions. |
| Comments | An unreasonable number of comments, ASCII banners and AI signatures in new and modified files. |

### The splash screen

Everything is drawn with `FlxSpriteUtil` primitives and animated with tweens:

1. Black screen.
2. A HaxeFlixel-inspired emblem (center diamond plus four corners) fades in, with its corners "unlit".
3. Outlined squares cross the screen in pairs, spinning, shifting through blue, purple, magenta and red.
4. Each pair that settles lights up one emblem corner and reveals one chunk of the title.
5. The squares end in a symmetric row, **CoLab Engine** is fully visible.
6. Short pause, then the regular engine transition into the original `TitleState`.

The sound is played once and stopped/faded when the state is left. All sprites are created once in `create()`.

## 4. AI Involvement

| Who | What they did |
| --- | --- |
| ChatGPT | Planning, specification and design of the modifications (the project spec this repository was built from). |
| Claude | Inspection of the Psych Engine source, implementation of the changes, comments, signatures and this README. |
| The human | Direction and supervision. Quality of the supervision: see the badge at the top. |

No other contributions are claimed for either assistant.

## 5. Credits

- **Psych Engine** by Shadow Mario, Riveren and contributors: the base project. See the [upstream README](https://github.com/ShadowMario/FNF-PsychEngine) for the complete credits list.
- **HaxeFlixel**: the library Psych Engine is built on. [github.com/HaxeFlixel/flixel](https://github.com/HaxeFlixel/flixel)
- **Claude** (Anthropic): coding assistant.
- **ChatGPT** (OpenAI): planning, specification and design assistant.
- **ElAbogato**: project owner, direction and supervision.

The crash handler in `Main.hx` keeps its original credit to sqirra-rng, as in upstream.

## 6. Based On

- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine), version 1.0.4 (`psychEngineVersion` in `MainMenuState.hx`).
- Psych Engine itself credits Friday Night Funkin' by ninjamuffin99.
- The splash animation is only *inspired by* the layout of HaxeFlixel's `FlxSplash`; no HaxeFlixel file is modified or copied into this project.

## 7. Installation and Compilation

This repository contains the `source/` files of the modified engine, not a full Psych Engine checkout.

1. Get a Psych Engine 1.0.4 project (assets, `Project.xml`, `setup/` scripts, etc.).
2. Copy the files of this repository over its `source/` folder, replacing the modified files listed below.
3. Add your splash sound at `assets/shared/sounds/splash.ogg` (see the note below).
4. Build as the upstream project does. From upstream's `docs/BUILDING.md`: Haxe 4.3.4 or greater, run the script in `setup/` (`windows.bat` or `unix.sh`), then:

```bash
lime test cpp
```

No new haxelibs are needed.

**About the sound file.** Psych Engine resolves `Paths.sound('splash')` to `assets/shared/sounds/splash.ogg` (or `mods/sounds/splash.ogg`), and upstream's `Project.xml` bundles `assets/shared`, so that is where the file has to be. A file placed in `assets/sounds/` would not be found nor bundled. For HTML5 builds the engine looks for `.mp3` instead of `.ogg`. If the file is missing the splash runs silent.

**About dependency versions.** Use the same versions as your existing Psych Engine setup. The new code was checked against HaxeFlixel 6.2.1.

## 8. Project Structure

```text
source/
├── Main.hx                              (modified) boots into the splash
└── states/
    ├── CustomSplashScreenState.hx       (new)      code-drawn boot splash
    ├── MainMenuState.hx                 (modified) left aligned options, top right corner stack
    ├── StoryMenuState.hx                (modified) left aligned weeks, top bar with difficulty selector
    ├── FreeplayState.hx                 (modified) centered layout, no character icons
    └── editors/
        └── MasterEditorMenu.hx          (modified) everything aligned left
README.md
LICENSE                                  (Apache License 2.0, copied from Psych Engine 1.0.4)
```

## 9. Known Limitations

- **It has been type-checked, not compiled or run.** The changed files were type-checked with the Haxe 4.3.7 compiler against HaxeFlixel 6.2.1, OpenFL 9.4.1 and Lime 8.2.2 (neko target, Lua/HScript/video/Discord disabled, a few unrelated lines of other files neutralized in a scratch copy because of version differences). The full `lime test cpp` build and the actual layouts on screen have **not** been verified.
- `splash.ogg` was not provided, so the animation length is not synchronized with it. All timings are constants at the top of `CustomSplashScreenState.hx`.
- Story Mode: the track list must stay in the bottom left and the week list must go left, which overlap. The weeks start at `WEEK_LIST_X` (346 px), right after the track column, instead of the far left edge.
- Main Menu: keyboard navigation is untouched, so Left/Right still jump between the main list and the two top right items.
- The window title and app name live in `Project.xml`, which is not part of this repository, so they still say Psych Engine.
- Changing mods in the Mods menu restarts the game, which plays the splash again.
- Freeplay centering relies on the width of each song title measured at creation time.

## 10. License and Third-Party Notices

- Psych Engine is licensed under the **Apache License 2.0**. The unmodified license text from the upstream repository (tag 1.0.4) is included as `LICENSE`. Modified files carry a notice stating that they were changed.
- HaxeFlixel is licensed under the **MIT License** (Copyright (c) 2009 Adam 'Atomic' Saltsman, (c) 2012 Matt Tuttle, (c) 2013 HaxeFlixel Team).
- This project does not declare a license of its own and does not claim ownership of the original Psych Engine or HaxeFlixel code. Friday Night Funkin' and any of its assets belong to their respective owners.
- The "© 2026 Anthropic PBC, OpenAI & ElAbogato" banners in the source are a joke signature, not a legal copyright notice.

*Written by Claude. Powered by ChatGPT. Supervised by questionable human decisions.*
