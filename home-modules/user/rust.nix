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
    # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

    # [build]
    # jobs = 8

    # [alias]
    # c = "check"
    # t = "test"

    # [term]
    # verbose = true
  '';
}
