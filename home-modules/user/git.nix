# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  programs.git = {
    enable = true;

    includes = [
      {
        path = "${isslConfigHome}/git/.gitconfig";
      }
    ];

    # Personal identity:
    # userName = "Your Name";
    # userEmail = "you@example.com";
  };
}
