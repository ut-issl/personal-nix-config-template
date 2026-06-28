# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ lib, enableZsh, ... }:

{
  imports = [
    ./user/bash.nix
    ./user/git.nix
    ./user/nix.nix
    ./user/python.nix
    ./user/rust.nix
  ]
  ++ lib.optionals enableZsh [ ./user/zsh.nix ];

  xdg.enable = true;
}
