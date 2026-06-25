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

    # The following commented block shows examples of personal preference settings.
    # Uncomment and adjust it if you want these preferences.
    #
    # autocd = true;
    #
    # shellAliases = {
    #   python = "python3";
    # };
    #
    # initContent = lib.mkAfter ''
    #   setopt auto_pushd
    #   setopt brace_ccl
    #   setopt globdots
    #
    #   zstyle ':completion:*' completer _oldlist _expand _complete _correct _approximate
    #   zstyle ':completion:*' menu select=long
    #
    #   alias -s py=python3
    # '';
  };
}
