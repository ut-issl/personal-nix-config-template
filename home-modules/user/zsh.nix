# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, lib, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = ".zsh";

    profileExtra = ''
      if [ -f "${isslConfigHome}/zsh/.zprofile" ]; then
        . "${isslConfigHome}/zsh/.zprofile"
      fi
    '';

    initContent = lib.mkBefore ''
      if [ -f "${isslConfigHome}/zsh/.zshrc" ]; then
        . "${isslConfigHome}/zsh/.zshrc"
      fi
    '';

    # Add your personal Zsh configuration below.
  };
}
