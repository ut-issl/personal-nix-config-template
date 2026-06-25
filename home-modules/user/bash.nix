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

    # Add your personal Bash configuration below.

    # The following commented block shows examples of personal preference settings.
    # Uncomment and adjust it if you want these preferences.
    #
    # shellAliases = {
    #   python = "python3";
    # };
    #
    # bashrcExtra = ''
    #   shopt -s autocd
    #   shopt -s cdspell
    #   shopt -s dotglob
    # '';
  };
}
