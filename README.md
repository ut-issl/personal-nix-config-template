<!--
SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
SPDX-FileCopyrightText: 2026 Riki Nakamura

SPDX-License-Identifier: MIT OR Apache-2.0
-->

# personal-nix-config-template

[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04%20%7C%2026.04-E95420.svg?style=flat&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Built with Nix](https://img.shields.io/badge/Built_with_Nix-41439a.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![License](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue.svg?style=flat)](#license)
[![prek](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/j178/prek/master/docs/assets/badge-v0.json)](https://github.com/j178/prek)
[![CI](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/ci.yaml)
[![Test](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/test.yaml/badge.svg)](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/test.yaml)

Personal Home Manager configuration template for the ISSL Ubuntu environment.

This template imports the shared configuration from [`ut-issl/issl-ubuntu-environment-setup`](https://github.com/ut-issl/issl-ubuntu-environment-setup)
and lets each user manage personal startup files and additional settings declaratively.

The ISSL shared files are deployed under `~/.config/issl` by the imported shared module.
The personal modules source or include those files from the Home Manager-managed user files.

For how this path fits into the shared environment, and for what that shared module provides, see
[setup with a personal config repository](https://github.com/ut-issl/issl-ubuntu-environment-setup/blob/v0.8.6/docs/11-setup-with-a-personal-config-repository.md).

> [!WARNING]
> This repository is an early-stage prototype and is under active development.
> It may be made private or deleted without prior notice.
> It is provided as-is, without user support or compatibility guarantees.
> Use it at your own risk.

## Getting Started

Create your own repository from this template using the **Use this template** button on GitHub,
then follow the steps below in it.

### 1. Prepare the Host

Run the shared host bootstrap script:

```console
bash <(curl -fsSL https://github.com/ut-issl/issl-ubuntu-environment-setup/releases/download/v0.8.6/bootstrap-host.sh)
```

The bootstrap script installs Nix and starts `nix-daemon` on systems without systemd.
Complete the GitHub SSH setup when prompted.

Open a new shell afterward so that `nix` is available on your `PATH`.

### 2. Clone Your Repository

Clone your repository using Git and OpenSSH provided through Nix:

```console
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git nixpkgs#openssh_gssapi \
  --command git clone git@github.com:<your-account>/<your-repository>.git
cd <your-repository>
```

### 3. Configure Your Git Identity

Edit [`home-modules/user/git.nix`](home-modules/user/git.nix) and set your Git identity.

Uncomment and update these lines:

```nix
user.name = "Your Name";
user.email = "you@example.com";
```

For other Git settings and any further customization, see [Customize Your Configuration](#customize-your-configuration).

### 4. Apply the Configuration

> [!CAUTION]
> The first `home-manager switch` **overwrites** the shell startup files that this configuration manages:
> `~/.profile`, `~/.bash_profile`, and `~/.bashrc` (plus `~/.zshenv` unless you turn Zsh off).
>
> On a fresh Ubuntu account these are just the default skeleton files,
> so there is nothing of yours to lose and you can safely proceed.
>
> If you have customized any of them and want to keep your version, first remove the `force = true` lines in [`home-modules/user/bash.nix`](home-modules/user/bash.nix#L49-L53)
> (and [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix#L79) for Zsh),
> then append `-b backup` to the first switch command below.
> That moves each existing file to `<file>.backup` instead of overwriting it.

Zsh is enabled by default, for the whole repository rather than per host.
To make this repository Bash-only instead, follow [Choose Your Shell](#choose-your-shell) first.

This template provides one configuration per kind of host:

- `.#user`: WSL, or a machine you reach only through a terminal
- `.#user-desktop`: a machine you use through its graphical desktop

The same repository serves all of your machines, so apply whichever matches the host in front of you:

```console
NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run .#home-manager -- switch --flake .#user --impure
```

Use `.#user-desktop` in that command on a desktop host.
[Install Desktop Applications](#install-desktop-applications) covers what belongs in that configuration.

> [!NOTE]
> `NIX_CONFIG` is only needed on this first run,
> because the shared ISSL configuration enables those features once it is applied.

## Agent Skills

This repository ships skills for coding agents that support [Agent Skills](https://agentskills.io)
(e.g. Codex or Claude Code).
Invoke a skill with `$<name>` in Codex or `/<name>` in Claude Code.

### `repo-setup`

Interactively walks you through the repository setup:
it checks your Git identity, asks which shell you want,
and sets up the [development tooling](#development-tooling) (pre-commit hooks and the opt-in features).

You can run it on the host you just set up, where Codex is installed by the applied configuration,
or on any other machine where an agent is already available (e.g. when preparing this repository from your current environment).

### `customize`

Assists [customizing your configuration](#customize-your-configuration) interactively —
from researching nixpkgs and the Home Manager options to editing the modules and validating the result.
State what you want when invoking it (e.g. `$customize add lazygit`).

### `sync-template`

Merges later improvements to this template into your repository.

A repository created from a GitHub template shares no history with it, so the two drift apart from the moment it is created.
This skill works out which template commit you last took — on the first run, the one your repository was created from —
merges everything since, resolves the conflicts, verifies the result and opens the pull request.
It records where it got to in `.template-base`, so the next run picks up from there.
Run it whenever you want to take the template's latest changes.

## Customize Your Configuration

All personal customization lives under [`home-modules/user/`](home-modules/user/).
The shared ISSL environment already installs many tools and deploys their base settings under `~/.config/issl`,
so your modules only need to layer your personal settings on top.

> [!NOTE]
> Nixpkgs settings belong in your modules as well:
> set them as `nixpkgs.config.*` instead of passing a `config` attribute to `import nixpkgs` in `flake.nix`.
> Options set in a module are merged with the shared ones, while such a `config` attribute is discarded.

Any change you make here takes effect only after you re-apply your configuration, as described in [Apply Your Changes](#apply-your-changes).

The `customize` skill can assist with these customizations interactively; see [Agent Skills](#agent-skills).

A new module under [`home-modules/user/`](home-modules/user/) is imported automatically.
It has to be tracked by Git, because a flake only sees tracked files.

A module that should apply only to some of your hosts, or only to one shell, wraps its settings in `lib.mkIf`:
`lib.mkIf config.local.desktop.enable` for the desktop-only ones,
as [`home-modules/user/desktop.nix`](home-modules/user/desktop.nix) does,
and `lib.mkIf config.issl.zsh.enable` for the Zsh-only ones,
as [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix) does.

Do not define `local.desktop.enable` in a module.
Whether a host is a desktop is decided by the configuration you apply,
and the flake check rejects any module definition that would change it.

### Choose Your Shell

The shared ISSL environment enables Zsh by default, and its Bash configuration applies either way.
If you want a Bash-only environment, uncomment the line in [`home-modules/user/shell.nix`](home-modules/user/shell.nix):

```nix
issl.zsh.enable = false;
```

Then add `zsh-enabled: false` to the `with:` block of the `user-repo` job in [`.github/workflows/test.yaml`](.github/workflows/test.yaml).
Without it the environment tests still look for Zsh and fail.

### Extend an Existing Module

Several tools already have a user module that sources or includes the shared ISSL files.
These modules load the shared settings first and leave space for your personal settings afterward.
Add your settings to the existing module rather than creating a new one:

- Git: [`home-modules/user/git.nix`](home-modules/user/git.nix)
- Bash: [`home-modules/user/bash.nix`](home-modules/user/bash.nix)
- Zsh: [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix)
- Python startup: [`home-modules/user/python.nix`](home-modules/user/python.nix)
- Cargo: [`home-modules/user/rust.nix`](home-modules/user/rust.nix)

Each file includes comments that show where to add personal settings and examples you can adapt.

### Install Extra Packages

List the packages you want in `home.packages`.
Any package from [Nixpkgs](https://search.nixos.org/packages) is available through `pkgs`.
Put them in a module such as [`home-modules/user/packages.nix`](home-modules/user/):

```nix
{ pkgs, ... }:

{
  home.packages = [
    pkgs.claude-code
    pkgs.lazygit
  ];
}
```

> [!NOTE]
> The shared ISSL configuration enables `allowUnfree`, so unfree packages such as `claude-code` install without extra setup.
> See [package management practices](https://github.com/ut-issl/issl-ubuntu-environment-setup/blob/v0.8.6/docs/13-package-management-practices.md#unfree-packages).

### Add a Module for a New Tool

When a package also comes with its own configuration,
it is easier to manage if you install the package and add its settings together in a dedicated module,
rather than listing the package alongside the others.

For example, `home-modules/user/julia.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = [ pkgs.julia ];

  home.file.".julia/config/startup.jl".text = ''
    ENV["JULIA_NUM_THREADS"] = string(Sys.CPU_THREADS)
  '';
}
```

### Install Desktop Applications

A graphical application installed through Nix appears in the desktop launcher like any other,
once you log out and back in after the switch that installs it.

Such an application is only worth installing on a host you actually use graphically,
so it goes behind `config.local.desktop.enable`, which sends it to `.#user-desktop` and keeps it out of `.#user`.
[`home-modules/user/desktop.nix`](home-modules/user/desktop.nix) is already gated and is where it goes by default.
Where a module of yours already covers the subject, put it there instead and wrap the graphical part in `lib.mkIf config.local.desktop.enable`.

An application that renders through OpenGL needs one more setting,
because Ubuntu does not provide the GPU drivers where a Nix-built application looks for them.
Turn `targets.genericLinux.gpu.enable` on in that module, add `pkgs` to its arguments, and add your application:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.local.desktop.enable {
    home.packages = [
      pkgs.obs-studio
      pkgs.vlc
    ];

    # This needs a one-time privileged setup on each machine.
    targets.genericLinux.gpu.enable = true;
  };
}
```

The next switch warns that the drivers are not set up yet.
Run the setup command it installs:

```console
sudo ~/.nix-profile/bin/non-nixos-gpu-setup
```

It installs a `systemd-tmpfiles` rule that recreates `/run/opengl-driver` on every boot,
so it does not need to be repeated after a reboot.
Run it again whenever a switch reports that the drivers need an update.

> [!NOTE]
> Applications the desktop already provides, such as the browser and the mail client, are best left as they are.
> See [package management practices](https://github.com/ut-issl/issl-ubuntu-environment-setup/blob/v0.8.6/docs/13-package-management-practices.md#gui-applications)
> for the other cases that are better left to the distribution.

## Apply and Maintain Your Configuration

### Update Dependencies

Update the pinned versions your configuration depends on:

```console
nix flake update
```

Then re-apply your configuration, as described in [Apply Your Changes](#apply-your-changes), to pick up the new versions.

### Apply Your Changes

After the first-time setup, the `home-manager` command is available directly.
Re-apply whenever you change your configuration:

```console
home-manager switch --flake .#user --impure
```

Use `.#user-desktop` instead on a machine you use through its graphical desktop.

### Validate Changes

Run:

```console
nix flake check --show-trace
```

You can also build the activation package directly:

```console
nix build .#homeConfigurations.user.activationPackage --impure
```

Build `.#homeConfigurations.user-desktop.activationPackage` instead to inspect a desktop-only change.

## Development Tooling

This template ships a few quality and maintenance tools.
Pre-commit hooks are part of the everyday workflow, while Renovate and Conventional Commits enforcement are opt-in.

### Pre-commit Hooks

This template uses [prek](https://prek.j178.dev), a faster drop-in replacement for [pre-commit](https://pre-commit.com),
with the hooks defined in [`.pre-commit-config.yaml`](.pre-commit-config.yaml).

> [!NOTE]
> `prek` is installed by this configuration once you apply the setup.
> If it is not available yet, complete the setup first by following [Getting Started](#getting-started).

Install the hooks once after cloning:

```console
prek install --hook-type pre-commit --hook-type pre-push
```

If you prefer `pre-commit`, substitute `uvx pre-commit` for `prek` in the command above.
The `check-prek` CI job runs the same hooks on every pull request.

### Renovate

[Renovate](https://docs.renovatebot.com) is preconfigured in [`.github/renovate.json5`](.github/renovate.json5)
to track Action SHAs, pinned tool versions inside [`ci.yaml`](.github/workflows/ci.yaml), and pre-commit hooks.
It is disabled by default; to opt in, change the `enabled: false` line to `true` (or remove it),
and make sure the Renovate GitHub App is installed for the repository.
The `validate-renovate-config` CI job checks the configuration whenever it changes.

### Conventional Commits

Commit messages and pull request titles can be checked against [Conventional Commits](https://www.conventionalcommits.org)
via [Commitizen](https://github.com/commitizen-tools/commitizen).
This is opt-in: uncomment [`lint-commit-messages` in `ci.yaml`](.github/workflows/ci.yaml)
and [`lint-pr-title` in `manage-pull-requests.yaml`](.github/workflows/manage-pull-requests.yaml) to enable it.
Linting the PR title is especially useful with squash merging,
since the PR title becomes the subject of the squashed commit by default.

> [!NOTE]
> `cz` (Commitizen) is installed by this configuration once you apply the setup.
> If it is not available yet, complete the setup first by following [Getting Started](#getting-started).

To author Conventional Commits interactively:

```console
cz commit
```

### REUSE Compliance

The [`reuse.yaml`](.github/workflows/reuse.yaml) CI workflow checks that every file carries
copyright and licensing information following the [REUSE](https://reuse.software) specification (see [License](#license)).

This check is scoped to the template repository itself:
an `if` guard on the `lint-reuse` job limits it to `ut-issl/personal-nix-config-template`,
so it does nothing in repositories derived from this template and can be left in place.
If you would rather not keep it, delete [`reuse.yaml`](.github/workflows/reuse.yaml).
Conversely, to enforce REUSE compliance in your own repository, remove the `if` guard from the `lint-reuse` job.

## License

The scaffolding provided by this template is licensed under either [MIT](LICENSES/MIT.txt) or [Apache-2.0](LICENSES/Apache-2.0.txt)
at your option, declared per file following the [REUSE](https://reuse.software) specification (see [REUSE.toml](REUSE.toml)).

Files you add to your personal configuration are yours, and you may license them however you like.
If you add files under paths already annotated in `REUSE.toml`, update the corresponding REUSE metadata as needed.
