# Starship

[Starship](https://starship.rs) replaces the prompt that the shared ISSL environment provides.
It takes over in both Bash and Zsh, and the shared prompt steps aside on its own, so nothing has to be disabled.

## Fragments

- `shell.nix` — add to `home-modules/user/shell.nix`.
- `fonts.nix` — add as `home-modules/user/fonts.nix`, and only if you want the icons described below.
  It installs a Nerd Font behind `config.local.desktop.enable`, so it applies to a desktop host alone.

## Icons and fonts

The default Starship configuration draws icons from a Nerd Font.
A terminal without one renders them as boxes or as replacement characters.
A font has to be installed where the terminal runs, not where the shell runs, which is why the two cases differ.

### On a native Linux desktop

Add `fonts.nix`, which installs `nerd-fonts.ubuntu-sans` as an example.
It provides "UbuntuSansMono Nerd Font", the patched version of the monospace font that Ubuntu 23.10 and later use.
Any other package under `pkgs.nerd-fonts`, such as `nerd-fonts.fira-code`, works as well:
they all carry the same icons and differ only in the underlying typeface.

### On WSL

The terminal is a Windows application and reads the fonts installed on Windows, not the ones installed here.
Install a Nerd Font on Windows and select it in the terminal settings.
`fonts.nix` changes nothing on such a host, since the configuration a WSL host applies leaves its gate closed.

### Without a font

Use a preset whose symbols need none, either from Home Manager:

```nix
programs.starship.presets = [ "plain-text-symbols" ];
```

or by writing the configuration file yourself:

```console
starship preset plain-text-symbols -o ~/.config/starship.toml
```

The two are exclusive.
`~/.config/starship.toml` stays yours while `programs.starship.settings` and `programs.starship.presets` are unset.
Defining either hands the file to Home Manager, which makes it read-only and stops `starship preset` from writing it.

See <https://starship.rs/presets/> for the other presets.
Note that `no-nerd-font` still uses Powerline symbols, which a plain font does not carry either.
