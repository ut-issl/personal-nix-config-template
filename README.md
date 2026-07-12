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

> [!WARNING]
> This repository is an early-stage prototype and is under active development.
> It may be made private or deleted without prior notice.
> It is provided as-is, without user support or compatibility guarantees.
> Use it at your own risk.

## Getting Started

### 1. Create Your Repository

Create your own repository from this template using the **Use this template** button on GitHub.

### 2. Prepare the Host

Run the shared host bootstrap script:

```console
bash <(curl -fsSL https://github.com/ut-issl/issl-ubuntu-environment-setup/releases/download/v0.4.0/bootstrap-host.sh)
```

The bootstrap script installs Nix and starts `nix-daemon` on systems without systemd.
It also offers to set up GitHub SSH access for private repositories and install Docker Engine.

Open a new shell afterward so that `nix` is available on your `PATH`.

### 3. Clone Your Repository

Clone your repository using Git and OpenSSH provided through Nix:

```console
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git nixpkgs#openssh \
  --command git clone git@github.com:<your-account>/<your-repository>.git
cd <your-repository>
```

### 4. Configure Your Git Identity

Edit [`home-modules/user/git.nix`](home-modules/user/git.nix) and set your Git identity
so that commits created from this environment have the correct author information.

Uncomment and update these lines:

```nix
userName = "Your Name";
userEmail = "you@example.com";
```

For other Git settings and any further customization, see [Customize Your Configuration](#customize-your-configuration).

### 5. Apply the Configuration

> [!CAUTION]
> The first `home-manager switch` **overwrites** the shell startup files that this configuration manages:
> `~/.profile`, `~/.bash_profile`, and `~/.bashrc` (plus `~/.zshenv` when you use `.#user-zsh`).
>
> On a fresh Ubuntu account these are just the default skeleton files,
> so there is nothing of yours to lose and you can safely proceed.
>
> If you have customized any of them and want to keep your version,
> first remove the `force = true` lines in [`home-modules/user/bash.nix`](home-modules/user/bash.nix#L49-L53)
> (and [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix#L78) for Zsh),
> then append `-b backup` to the first switch command below.
> That moves each existing file to `<file>.backup` instead of overwriting it.

This template provides two Home Manager configurations:

- `.#user`: Bash-based configuration
- `.#user-zsh`: Bash + Zsh configuration

To apply the Bash + Zsh configuration, run:

```console
nix --extra-experimental-features "nix-command flakes" run .#home-manager -- switch --flake .#user-zsh --impure
```

Use `.#user` instead if you want the Bash-only configuration.

> [!NOTE]
> The `--extra-experimental-features` flag is only needed on this first run,
> because the shared ISSL configuration enables those features once it is applied.

## Customize Your Configuration

All personal customization lives under [`home-modules/user/`](home-modules/user/).
The shared ISSL environment already installs many tools and deploys their base settings under `~/.config/issl`,
so your modules only need to layer your personal settings on top.

Any change you make here takes effect only after you re-apply your configuration, as described in [Apply Your Changes](#apply-your-changes).

Whenever you add a new module, import it from [`home-modules/user.nix`](home-modules/user.nix):

```nix
imports = [
  ./user/bash.nix
  ./user/git.nix
  ./user/nix.nix
  ./user/python.nix
  ./user/rust.nix
  ./user/packages.nix # your new module
]
++ lib.optionals enableZsh [ ./user/zsh.nix ];
```

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
> This template enables `allowUnfree`, so unfree packages such as `claude-code` install without extra setup.

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

## Apply and Maintain Your Configuration

### Update Dependencies

Update the pinned versions your configuration depends on:

```console
nix flake update
```

Then re-apply your configuration, as described in [Apply Your Changes](#apply-your-changes),
to pick up the new versions.

### Apply Your Changes

After the first-time setup, the `home-manager` command is available directly.
Re-apply whenever you change your configuration:

```console
home-manager switch --flake .#user-zsh --impure
```

Use `.#user` instead if you use the Bash-only configuration.

### Validate Changes

Run:

```console
nix flake check --show-trace
```

You can also build each activation package directly:

```console
nix build .#homeConfigurations.user.activationPackage --impure
nix build .#homeConfigurations.user-zsh.activationPackage --impure
```

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
