# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    profileExtra = ''
      if [ -f "${isslConfigHome}/bash/.bash_profile" ]; then
        . "${isslConfigHome}/bash/.bash_profile"
      fi
    '';

    bashrcExtra = ''
      if [ -f "${isslConfigHome}/bash/.bashrc" ]; then
        . "${isslConfigHome}/bash/.bashrc"
      fi
    '';
  };
}
