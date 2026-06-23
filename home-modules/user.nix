{ lib, enableZsh, ... }:

{
  imports = [
    ./user/bash.nix
    ./user/git.nix
  ]
  ++ lib.optionals enableZsh [ ./user/zsh.nix ];

  xdg.enable = true;
}
