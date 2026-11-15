---
name: customize
description: >-
  Assist customization of this personal Home Manager configuration:
  installing tools, configuring programs, and porting existing dotfiles into the personal modules.
  Use when the user asks to add or install a tool or package,
  to add or change the settings of a program (aliases, editor, prompt, startup files, and so on),
  or to migrate settings from their existing dotfiles.
  Do not use for the initial repository setup (that is the repo-setup skill) or for routine dependency updates.
---

# Customize the Configuration

Help the user customize their personal Home Manager configuration, one request at a time:
install a tool, configure a program, or port settings from existing dotfiles.
When one message asks for several things, take them all through steps 1 to 4 first and present the plan once,
then implement and validate them together.

Follow the conventions of the "Customize Your Configuration" section of `README.md`.
Converse in the language the user writes in, but keep all edits (code, comments, commit messages, etc.) in English.
Leave all changes uncommitted; committing and pushing are up to the user unless explicitly requested.
Never run `home-manager switch` without an explicit yes from the user (see step 7).
Run `nix` commands one at a time, never several at once.
If one stops for exceeding the shared memory limit, which it reports, tell the user instead of retrying it.
Never write secrets (tokens, private keys, credentials) into the repository.
If the user pastes one into the conversation, recommend revoking it,
and where the program supports it, have the configuration read it at run time from a file outside the repository.

This repository manages globally available user tools with Nix and Home Manager,
following the shared package management practices (`docs/13-package-management-practices.md` in `ut-issl/issl-environment`).
Never install the requested tool with `apt`, `cargo install`, `uv tool install`, `npm install -g`, or the like;
if the request is really a project-local dependency or a system-level package,
say that it does not belong in this repository and point to those practices instead.

## 1. Understand the request and the environment

Identify what the user wants: a new tool, settings for a program, or porting existing dotfiles.
Ask only if the request is ambiguous.

Check whether `nix` is available (`command -v nix`).
Without Nix, still do the research via the web and implement the change,
but clearly report at the end that local validation was skipped and the change is unverified.

## 2. Check what already exists

The shared ISSL environment installs many tools and deploys their base settings under `~/.config/issl`.
Before adding anything, check whether the tool is already provided:

- the shared modules: `home-modules/` of `ut-issl/issl-environment` at the version pinned in `flake.nix`;
- this repository's own modules under `home-modules/`;
- whether the command is already on `PATH` on the machine to be configured, whether or not it has been applied yet —
  and if so, where it resolves to.
  When that machine is not the one you run on, ask the user instead.

If the command resolves into the Nix store (directly or via `~/.nix-profile`),
the tool is already provided; only the personal settings need to be layered on top.
Follow the existing pattern: the shared files are loaded first, personal additions come after
(see `home-modules/bash/bash.nix` or `home-modules/git/git.nix` for examples).

If the command resolves outside the Nix store, find out how it was installed —
the user may not remember or even know it is there.
Check the usual suspects: `dpkg -S` for `apt`, `~/.cargo/bin` for `cargo install`,
`~/.local/bin` for user-local installs (`uv tool install`, `pipx`, and installers that put their binary there;
`uv tool list` tells which came from `uv`), and `npm list -g` for `npm install -g`.
Then offer to migrate it into this configuration, except system-level `apt` packages, which stay with `apt`.
The old installation is removed only at the very end (see step 8).

If a recipe under `recipes/` covers the request, follow it instead of working the setup out again.
Its `README.md` states what the setup needs outside this repository,
and its Nix fragments name the modules their lines belong to.
Merge those lines into the modules, and leave `recipes/` itself untouched:
it comes from the template, so edits there conflict on the next sync.
Copy any file a fragment deploys into the module directory as well, at the relative path that the fragment refers to.

## 3. Research the package and its options

For a new tool:

- Find the package with `nix-search`, which the shared configuration installs.
  It queries <https://search.nixos.org/packages> without evaluating Nixpkgs locally.
  Search by words, `--name` or `--program`, on the channel of the pinned release.
  That channel follows from the `original.ref` of the `nixpkgs` entry in `flake.lock`.
  For example, `nixos-26.05` is `--channel 26.05`, and `nixos-unstable` is `--channel unstable`.
  Without `nix-search`, use <https://search.nixos.org/packages> itself.
  Never run `nix search`, which evaluates the whole package set and needs several GiB of memory.
- Confirm the version at the pinned revision, since the search covers a channel that may have moved past the pin.
  Take `locked.rev` of the `nixpkgs` entry in `flake.lock` and run `nix eval github:NixOS/nixpkgs/<rev>#<name>.version`.
  The shared configuration replaces some packages with newer ones through an overlay, such as the coding agents;
  `nix eval --impure .#homeConfigurations.user.pkgs.<name>.version` shows the version the configuration actually uses.
- Check whether Home Manager has a matching module (`programs.<tool>` or `services.<tool>`):
  on an applied machine `man home-configuration.nix` documents the installed version and is the source of truth;
  otherwise use the Home Manager manual for the matching release.
- Unfree packages are fine: the shared ISSL configuration already sets `allowUnfree = true`.
- If the package is not in Nixpkgs, report the options honestly and let the user decide:
  do without it, add another flake input that provides it, or manage it outside Nix —
  the last is the user's own call and out of scope for this skill.
  Never add flake inputs or overlays without an explicit yes.

## 4. Decide where the change goes

Apply the README's conventions:

- A module under `home-modules/` already covers the subject (such as `bash`, `zsh`, `git`, `python`, `rust`):
  extend that module at the comments marked for personal additions instead of creating a new one.
  A package belongs there too when the module covers what it is for.
- None does, and the tool brings its own configuration: create `home-modules/<tool>/<tool>.nix`, named after the tool;
  prefer the Home Manager `programs.<tool>` options when they exist,
  otherwise combine `home.packages` with `home.file` / `xdg.configFile`.
- None does, and it is only a package: put it in a module named after what such packages are for,
  as the shared environment names `utils` and `dev`;
  create `home-modules/<purpose>/<purpose>.nix` if no module of that purpose exists yet.
- A graphical application: follow "Install Desktop Applications" in `README.md`.
  It goes behind `config.local.desktop.enable`, so that it stays out of the hosts the user only reaches through a terminal:
  in `home-modules/desktop/desktop.nix`, which is already gated,
  or, where a module already covers its subject, in that module wrapped in `lib.mkIf config.local.desktop.enable`.
  One that renders through OpenGL also needs `targets.genericLinux.gpu.enable` turned on behind the same gate.
  Signs that it does: its package wraps or links libGL or Mesa, it is built on Electron, Chromium, or Firefox,
  or it is a GPU-accelerated terminal.
  When unsure, tell the user that turning it on asks each machine for a one-time privileged setup, and let them decide.
  Some graphical applications are better left to the distribution, such as ones that depend on its input methods:
  check the "Host integration" criterion of the package management practices, and tell the user when it applies.
- A new module directory under `home-modules/` is imported automatically, but it has to be tracked by Git.
  The directory and the Nix file inside it carry the same name,
  and a configuration file the module deploys sits beside that file.
  A module for only some hosts or only one shell wraps its settings in `lib.mkIf`:
  `lib.mkIf config.local.desktop.enable` for the desktop-only ones, as `home-modules/desktop/desktop.nix` does,
  and `lib.mkIf config.issl.zsh.enable` for the Zsh-only ones, as `home-modules/zsh/zsh.nix` does.
  Never define `local.desktop.enable` itself in a module; `flake.nix` sets it per configuration,
  and the `desktop-axis` check in `flake.nix` rejects any module definition that would change it.

A `programs.<tool>` module can do more than install the tool:
it can take over a configuration file as a read-only link, or turn on integrations such as shell key bindings by default.
The existing setup already steers around this where it matters:
the shared environment sets Git up with `home.packages` and a file under `~/.config/issl` rather than `programs.git`,
so that `~/.config/git/config` stays the user's,
and the Claude Code recipe leaves `programs.claude-code.settings` unset,
since Claude Code writes `~/.claude/settings.json` itself.
Codex writes its `config.toml` the same way, which `programs.codex.settings` would make read-only.
Before using such a module, check what it deploys and enables by default, in its options and in the build result's `home-files`.
When it takes over a file the tool writes itself, or turns on what the user did not ask for,
present the trade-off before editing.

If more than one placement is reasonable, present the options briefly with a recommendation
and let the user choose before editing.

## 5. Port existing dotfiles (when requested)

Read the dotfiles the user wants to port and go through their content together:

- Skip parts the shared ISSL environment already provides.
- Translate parts that map to Home Manager options into those options.
- Keep the rest as verbatim blocks in the matching extra hooks (e.g. `bashrcExtra`, `initContent`) or as `home.file` content.
- Preserve the layering: shared settings load first, ported personal settings after.
- Filter out secrets and machine-specific leftovers; confirm anything questionable with the user.
- Tell the user which original files to move aside once the change is applied:
  a leftover `~/.gitconfig`, for example, is read after `~/.config/git/config` and overrides it.

## 6. Implement and validate

Match the style of the existing modules (formatting is enforced by nixfmt via the pre-commit hooks).

When this repository enforces REUSE compliance
(`.github/workflows/lint-reuse-compliance.yaml` is present
and its job no longer carries `if: github.repository == 'ut-issl/personal-nix-config-template'`),
every file the change creates needs copyright and licensing information.
A file that only changes keeps the information it has, including one that takes in lines from a recipe.

- Give a file that takes comments an SPDX header in the layout `home-modules/git/git.nix` uses,
  with the holders and license below rather than the ones that file names.
  Declare a file that cannot take one, such as JSON, in a new `[[annotations]]` table of `REUSE.toml`
  with those holders and license, not by adding its path to an existing table.
- A file the user writes is theirs:
  name `user.name` from `home-modules/git/git.nix` as its only copyright holder, with the current year,
  and ask the user for the name when it is not set there.
  For the license, follow the files whose only copyright holder is that name;
  when there are none yet, or they differ, ask the user which license to use,
  suggesting `MIT OR Apache-2.0`, which the template uses (see "License" in `README.md`).
- A file copied from a recipe stays the recipe authors' work:
  take its holders and license (`MIT-0`) from the `recipes/**` table of `REUSE.toml`,
  and add the user as a further holder only when they change the copy beyond what the recipe says to fill in.
- After adding the information, run `reuse download --all` (or `uvx reuse download --all`),
  which adds the text of each license the files name that `LICENSES/` does not hold yet.

Then validate:

- Run `prek run --files <changed files> --skip no-commit-to-branch` (or via `uvx prek`) and fix what it reports.
- When REUSE compliance is enforced, also run `reuse lint` (or `uvx reuse lint`), which the hooks do not cover.
- With Nix, build the `checks` of `flake.nix` one at a time, for the system of this machine:
  `x86_64-linux` or `aarch64-linux`, matching the `x86_64` or `aarch64` that `uname -m` prints.
  Do not run `nix flake check` for this: it evaluates every check in one process, which takes well over a GiB.
  List the checks, then build each listed name in turn:

  ```sh
  nix eval --json .#checks.<system> --apply builtins.attrNames
  nix build --no-link --show-trace .#checks.<system>.<name>
  ```

  The checks include the activation packages, so this also catches build failures.
  If the change edits the `packages` or `formatter` outputs of `flake.nix`,
  also evaluate `.#formatter.<system>.drvPath` and `.#packages.<system>.<name>.drvPath` for each package
  with `nix eval --raw --show-trace`, which `nix flake check` would otherwise have covered.
- Then build the activation package to inspect the result:

  ```sh
  nix build --impure .#homeConfigurations.user.activationPackage
  ```

  For a desktop-only change, also build the desktop configuration into a second link,
  and compare the two to confirm that the change stays out of `.#user`:

  ```sh
  nix build --impure -o result-desktop .#homeConfigurations.user-desktop.activationPackage
  diff -r result/home-files result-desktop/home-files
  diff <(ls result/home-path/bin) <(ls result-desktop/home-path/bin)
  ```

  The build result shows what the configuration actually produces:

  - `result/home-path/bin` holds the binaries the configuration installs.
  - `result/home-files` holds the files deployed through `home.file` and `xdg.configFile`,
    so a deployed file can be compared against its source with `cmp`.
  - `result/activate` is the activation script that Home Manager runs on `switch`.

  Remove the `result` symlink (and `result-desktop`) when done.

## 7. Offer to apply

Applying is optional and requires an explicit yes.
Ask which configuration this host uses (`.#user` or `.#user-desktop`) if not already known,
then offer to run the switch with that target:

```sh
home-manager switch --flake .#user --impure
```

Substitute `.#user-desktop` when that is the host's configuration.

If the user declines or `home-manager` is not available, point to the "Apply Your Changes" section of `README.md`.
After a successful switch, verify the result where easy (e.g. the new command is on `PATH`).

A graphical application takes two more steps that only the user can take.
Tell them to log out and back in, so that the desktop environment picks the application up.
If `targets.genericLinux.gpu.enable` was turned on,
tell them to run `sudo ~/.nix-profile/bin/non-nixos-gpu-setup` once on this machine, as the switch itself warns.

## 8. Clean up and wrap up

If an installation outside the Nix store was migrated into this configuration (step 2),
remove the old installation now, so it does not shadow the Nix-managed one on `PATH`.
Do this only after the new configuration has been applied and the new version is verified to work,
and confirm the exact uninstall command with the user
(e.g. `uv tool uninstall`, `cargo uninstall`, `npm uninstall -g`) before running it yourself.

Finally, summarize what was changed and what was validated or skipped, and leave the changes uncommitted.
