# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  home.file.".cargo/config.toml".text = ''
    include = [
      { path = "${isslConfigHome}/rust/config.toml", optional = true },
    ]

    # Add your personal Cargo configuration below.
  '';
}
