# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, lib, ... }:

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

    bashrcExtra = lib.mkMerge [
      ''
        if [ -f "${isslConfigHome}/bash/.bashrc" ]; then
          . "${isslConfigHome}/bash/.bashrc"
        fi
      ''

      (lib.mkAfter ''
        # Add personal Bash commands below.
        # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

        # shopt -s autocd
        # shopt -s cdspell
        # shopt -s dotglob
      '')
    ];

    # Add personal Home Manager options for Bash below.
    # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

    # shellAliases = {
    #   python = "python3";
    # };
  };
}
