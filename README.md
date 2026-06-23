<!--
SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo

SPDX-License-Identifier: MIT OR Apache-2.0
-->

# personal-nix-config-template

[![prek](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/j178/prek/master/docs/assets/badge-v0.json)](https://github.com/j178/prek)
[![CI](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/ut-issl/personal-nix-config-template/actions/workflows/ci.yaml)

Personal Home Manager configuration template for the ISSL Ubuntu environment.

This template imports the shared configuration from [`ut-issl/issl-ubuntu-environment-setup`](https://github.com/ut-issl/issl-ubuntu-environment-setup)
and lets each user manage personal startup files and additional settings declaratively.

The ISSL shared files are deployed under `~/.config/issl` by the imported shared module.
The personal modules source or include those files from the Home Manager-managed user files.

## How to Use

### Create Your Personal Repository

Create a new repository from this template, then clone your repository:

```console
git clone git@github.com:<your-account>/<your-repository>.git
cd <your-repository>
```

### Configure Git Identity

Before applying the configuration, edit [`home-modules/user/git.nix`](home-modules/user/git.nix) and set your Git identity.
This is required so commits created from this environment have the correct author information.

Uncomment and update these lines:

```nix
userName = "Your Name";
userEmail = "you@example.com";
```

For other Git settings and any further customization, see [Customize Your Configuration](#customize-your-configuration).

### Apply the Configuration

This template provides two Home Manager configurations:

- `.#user`: Bash-based configuration
- `.#user-zsh`: Bash + Zsh configuration

To apply the Bash + Zsh configuration, run:

```console
nix run .#home-manager -- switch --flake .#user-zsh --impure
```

Use `.#user` instead if you want the Bash-only configuration.

> [!TIP]
> This first run installs the `home-manager` command and applies the shared Nix settings.
> After that, re-run with the `home-manager` command directly whenever you change your configuration:
>
> ```console
> home-manager switch --flake .#user-zsh --impure
> ```

## Customize Your Configuration

All personal customization lives under [`home-modules/user/`](home-modules/user/).
The shared ISSL environment already installs many tools and deploys their base settings under `~/.config/issl`,
so your modules only need to layer your personal settings on top.

Whenever you add a new module, import it from [`home-modules/user.nix`](home-modules/user.nix):

```nix
imports = [
  ./user/bash.nix
  ./user/git.nix
  ./user/packages.nix # your new module
]
++ lib.optionals enableZsh [ ./user/zsh.nix ];
```

### Extend an Existing Module

Some tools already have a user module ([`bash.nix`](home-modules/user/bash.nix), [`zsh.nix`](home-modules/user/zsh.nix),
[`git.nix`](home-modules/user/git.nix)) that sources the shared ISSL files.
Add your settings to the existing module rather than creating a new one.

For example, Git can be configured in the `programs.git` block of [`home-modules/user/git.nix`](home-modules/user/git.nix):

```nix
aliases = {
  last = "log -1 HEAD";
  unstage = "reset HEAD --";
};

extraConfig = {
  commit.verbose = true;
  merge.conflictStyle = "zdiff3";
  rebase.autosquash = true;
};
```

Bash and Zsh use the `programs.bash` or `programs.zsh` block of
[`home-modules/user/bash.nix`](home-modules/user/bash.nix) or [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix):

```nix
shellAliases = {
  gs = "git status";
  gd = "git diff";
};

sessionVariables = {
  EDITOR = "vim";
};
```

Zsh-specific options and completion styling go in `initContent`, for example:

```nix
programs.zsh.initContent = lib.mkAfter ''
  setopt auto_cd
  setopt correct

  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
'';
```

### Add a Module for an Installed Tool

Some tools (for example Rust and Python) are installed by the shared configuration but have no user module yet.
Create a new module to add your personal settings; the tool itself is already provided,
so you do not need to install it again.

For example, add personal Cargo settings in `home-modules/user/rust.nix`:

```nix
{ ... }:

{
  home.file.".cargo/config.toml".text = ''
    [build]
    jobs = 8
  '';
}
```

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

## Maintain Your Configuration

### Update Inputs

Update pinned inputs:

```console
nix flake update
```

Then apply the configuration again, as described in [Apply the Configuration](#apply-the-configuration),
to pick up the new versions.

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

## License

The scaffolding provided by this template is licensed under either [MIT](LICENSES/MIT.txt) or [Apache-2.0](LICENSES/Apache-2.0.txt)
at your option, declared per file following the [REUSE](https://reuse.software) specification (see [REUSE.toml](REUSE.toml)).

Files you add to your personal configuration are yours, and you may license them however you like.
If you add files under paths already annotated in `REUSE.toml`, update the corresponding REUSE metadata as needed.
