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

## Getting Started

### 1. Create Your Repository

Create your own repository from this template using the **Use this template** button on GitHub.

### 2. Install Nix

If Nix is not installed yet, install it with the official multi-user installer:

```console
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

Open a new shell afterward so that `nix` is available on your `PATH`.

> [!IMPORTANT]
> Nix uses a background daemon, and on WSL or other systems without systemd it may not be running.
> If a Nix command cannot reach the daemon, start it manually and retry:
>
> ```console
> sudo nix-daemon &
> ```

### 3. Set Up GitHub SSH Access

Generate a key, creating `~/.ssh` first if it does not exist:

```console
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519
```

Add the GitHub host to `~/.ssh/config`:

```console
printf 'Host github.com\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/github_ed25519\n' >> ~/.ssh/config
```

Register the public key (`~/.ssh/github_ed25519.pub`) at <https://github.com/settings/keys>, then verify the connection:

```console
ssh -T git@github.com
```

### 4. Clone Your Repository

Clone your repository using Git provided through Nix:

```console
nix-shell -p git --run "git clone git@github.com:<your-account>/<your-repository>.git"
cd <your-repository>
```

### 5. Configure Your Git Identity

Edit [`home-modules/user/git.nix`](home-modules/user/git.nix) and set your Git identity
so that commits created from this environment have the correct author information.

Uncomment and update these lines:

```nix
userName = "Your Name";
userEmail = "you@example.com";
```

For other Git settings and any further customization, see [Customize Your Configuration](#customize-your-configuration).

### 6. Apply the Configuration

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
  ./user/packages.nix # your new module
]
++ lib.optionals enableZsh [ ./user/zsh.nix ];
```

### Extend an Existing Module

Several tools already have a user module that sources or includes the shared ISSL files:
[`bash.nix`](home-modules/user/bash.nix), [`zsh.nix`](home-modules/user/zsh.nix),
[`git.nix`](home-modules/user/git.nix), [`python.nix`](home-modules/user/python.nix),
and [`rust.nix`](home-modules/user/rust.nix).
Add your settings to the existing module rather than creating a new one.

For example, Git can be configured in the `programs.git` block of [`home-modules/user/git.nix`](home-modules/user/git.nix):

```nix
programs.git = {
  aliases = {
    last = "log -1 HEAD";
    unstage = "reset HEAD --";
  };

  extraConfig = {
    commit.verbose = true;
    merge.conflictStyle = "zdiff3";
    rebase.autosquash = true;
  };
};
```

Bash and Zsh use the `programs.bash` or `programs.zsh` block of
[`home-modules/user/bash.nix`](home-modules/user/bash.nix) or [`home-modules/user/zsh.nix`](home-modules/user/zsh.nix):

```nix
programs.bash = {
  shellAliases = {
    gs = "git status";
    gd = "git diff";
  };

  sessionVariables = {
    EDITOR = "vim";
  };
};
```

Zsh-specific options and completion styling go in `initContent`, for example:

```nix
programs.zsh = {
  autocd = true;

  shellAliases = {
    python = "python3";
  };

  initContent = lib.mkAfter ''
    setopt auto_pushd

    zstyle ':completion:*' completer _oldlist _expand _complete _correct _approximate
    zstyle ':completion:*' menu select=long

    alias -s py=python3
  '';
};
```

Python interactive-shell startup goes in [`home-modules/user/python.nix`](home-modules/user/python.nix),
after the block that loads the shared startup:

```nix
home.file.".python/.pythonrc.py".text = ''
  import runpy
  from pathlib import Path

  shared_pythonrc = Path("${isslConfigHome}/python/pythonrc.py")
  if shared_pythonrc.is_file():
      runpy.run_path(str(shared_pythonrc), run_name="__main__")

  from datetime import datetime, timedelta  # noqa: F401
'';
```

Personal Cargo settings go in [`home-modules/user/rust.nix`](home-modules/user/rust.nix),
alongside the include of the shared configuration:

```nix
home.file.".cargo/config.toml".text = ''
  include = [
    { path = "${isslConfigHome}/rust/config.toml", optional = true },
  ]

  [build]
  jobs = 8
'';
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

## License

The scaffolding provided by this template is licensed under either [MIT](LICENSES/MIT.txt) or [Apache-2.0](LICENSES/Apache-2.0.txt)
at your option, declared per file following the [REUSE](https://reuse.software) specification (see [REUSE.toml](REUSE.toml)).

Files you add to your personal configuration are yours, and you may license them however you like.
If you add files under paths already annotated in `REUSE.toml`, update the corresponding REUSE metadata as needed.
