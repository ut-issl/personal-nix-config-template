# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ lib, ... }:

{
  imports = lib.mapAttrsToList (name: _: ./user + "/${name}") (
    lib.filterAttrs (name: type: type == "directory" || lib.hasSuffix ".nix" name) (
      builtins.readDir ./user
    )
  );

  xdg.enable = true;
}
