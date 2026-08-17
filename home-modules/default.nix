# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ lib, ... }:

{
  imports = lib.mapAttrsToList (name: _: ./user + "/${name}") (
    lib.filterAttrs (
      name: type:
      if type == "directory" then
        builtins.pathExists (./user + "/${name}/default.nix")
      else
        lib.hasSuffix ".nix" name
    ) (builtins.readDir ./user)
  );

  options.local.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether this host runs a graphical desktop, as opposed to WSL or a headless server.
      Modules under `user/` gate their desktop-only settings on this option,
      and `flake.nix` sets it per Home Manager configuration.
    '';
  };

  config.xdg.enable = true;
}
