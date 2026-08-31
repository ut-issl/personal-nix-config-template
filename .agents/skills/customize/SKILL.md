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

Follow the conventions of the "Customize Your Configuration" section of `README.md`.
Converse in the language the user writes in, but keep all edits (code, comments, commit messages, etc.) in English.
Leave all changes uncommitted; committing and pushing are up to the user unless explicitly requested.
Never run `home-manager switch` without an explicit yes from the user (see step 7).
Never write secrets (tokens, private keys, credentials) into the repository.

This repository manages globally available user tools with Nix and Home Manager,
following the shared package management practices
(`docs/13-package-management-practices.md` in `ut-issl/issl-ubuntu-environment-setup`).
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

- the shared modules: `home-modules/` of `ut-issl/issl-ubuntu-environment-setup` at the version pinned in `flake.nix`;
- this repository's own modules under `home-modules/user/`;
- on an applied machine, whether the command is already on `PATH` — and if so, where it resolves to.

If the command resolves into the Nix store (directly or via `~/.nix-profile`),
the tool is already provided; only the personal settings need to be layered on top.
Follow the existing pattern: the shared files are loaded first, personal additions come after
(see `home-modules/user/bash.nix` or `git.nix` for examples).

If the command resolves outside the Nix store, find out how it was installed —
the user may not remember or even know it is there.
Check the usual suspects: `dpkg -S` for `apt`, `~/.cargo/bin` for `cargo install`,
`uv tool list` / `~/.local/bin` for `uv tool install`, and `npm list -g` for `npm install -g`.
Then offer to migrate it into this configuration, except system-level `apt` packages, which stay with `apt`.
The old installation is removed only at the very end (see step 8).

If a recipe under `examples/` covers the request, follow it instead of working the setup out again.
Its `README.md` states what the setup needs outside this repository,
and its Nix fragments name the modules their lines belong to.
Merge those lines into the modules, and leave `examples/` itself untouched:
it comes from the template, so edits there conflict on the next sync.

## 3. Research the package and its options

For a new tool:

- Look the package up in nixpkgs at the pinned revision:
  read the `nixpkgs` entry's `locked.rev` from `flake.lock` and run `nix search github:NixOS/nixpkgs/<rev> <name>`.
  Without Nix, use <https://search.nixos.org/packages>, noting that its channel may differ from the pin.
- Check whether Home Manager has a matching module (`programs.<tool>` or `services.<tool>`):
  on an applied machine `man home-configuration.nix` documents the installed version and is the source of truth;
  otherwise use the Home Manager manual for the matching release.
- Unfree packages are fine: the shared ISSL configuration already sets `allowUnfree = true`.
- If the package is not in nixpkgs, report the options honestly and let the user decide:
  do without it, add another flake input that provides it, or manage it outside Nix —
  the last is the user's own call and out of scope for this skill.
  Never add flake inputs or overlays without an explicit yes.

## 4. Decide where the change goes

Apply the README's conventions:

- The tool already has a module under `home-modules/user/` (bash, zsh, git, python, rust):
  extend that module at the comments marked for personal additions instead of creating a new one.
- A package with no settings: add it to `home.packages` in `home-modules/user/packages.nix`
  (create the file if it does not exist yet).
- A package together with its settings: create a dedicated module `home-modules/user/<tool>.nix`;
  prefer the Home Manager `programs.<tool>` options when they exist,
  otherwise combine `home.packages` with `home.file` / `xdg.configFile`.
- A graphical application: follow "Install Desktop Applications" in `README.md`.
  It goes behind `config.local.desktop.enable`,
  so that it stays out of the hosts the user only reaches through a terminal:
  in `home-modules/user/desktop.nix`, which is already gated,
  or, where a module already covers its subject, in that module wrapped in `lib.mkIf config.local.desktop.enable`.
  One that renders through OpenGL also needs `targets.genericLinux.gpu.enable` turned on behind the same gate.
- A new module under `home-modules/user/` is imported automatically, but it has to be tracked by Git.
  A module for only some hosts or only one shell wraps its settings in `lib.mkIf`:
  `lib.mkIf config.local.desktop.enable` for the desktop-only ones, as `home-modules/user/desktop.nix` does,
  and `lib.mkIf config.issl.zsh.enable` for the Zsh-only ones, as `home-modules/user/zsh.nix` does.
  Never define `local.desktop.enable` itself in a module; `flake.nix` sets it per configuration,
  and the flake check rejects any module definition that would change it.

If more than one placement is reasonable, present the options briefly with a recommendation
and let the user choose before editing.

## 5. Port existing dotfiles (when requested)

Read the dotfiles the user wants to port and go through their content together:

- Skip parts the shared ISSL environment already provides.
- Translate parts that map to Home Manager options into those options.
- Keep the rest as verbatim blocks in the matching extra hooks
  (e.g. `bashrcExtra`, `initContent`) or as `home.file` content.
- Preserve the layering: shared settings load first, ported personal settings after.
- Filter out secrets and machine-specific leftovers; confirm anything questionable with the user.

## 6. Implement and validate

Match the style of the existing modules (formatting is enforced by nixfmt via the pre-commit hooks).

Then validate:

- Run `prek run --files <changed files> --skip no-commit-to-branch` (or via `uvx prek`) and fix what it reports.
- With Nix, run `nix flake check --show-trace`;
  this builds the activation packages in `checks`, so it also catches build failures.
- Then build the activation package to inspect the result:

  ```console
  nix build .#homeConfigurations.user.activationPackage --impure
  ```

  Build `.#homeConfigurations.user-desktop.activationPackage` instead for a desktop-only change.

  The build result shows what the configuration actually produces:

  - `result/home-path/bin` holds the binaries the configuration installs.
  - `result/home-files` holds the files deployed through `home.file` and `xdg.configFile`,
    so a deployed file can be compared against its source with `cmp`.
  - `result/activate` is the activation script that Home Manager runs on `switch`.

  Remove the `result` symlink when done.

## 7. Offer to apply

Applying is optional and requires an explicit yes.
Ask which configuration this host uses (`.#user` or `.#user-desktop`) if not already known,
then offer to run the switch with that target:

```console
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
