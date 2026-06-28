# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, pkgs, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  nix.package = pkgs.nix;

  nix.extraOptions = ''
    !include ${isslConfigHome}/nix/nix.conf
  '';
}
