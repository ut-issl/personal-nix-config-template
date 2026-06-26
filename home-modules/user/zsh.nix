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

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [ -f "${isslConfigHome}/zsh/.zshrc" ]; then
          . "${isslConfigHome}/zsh/.zshrc"
        fi
      '')

      (lib.mkAfter ''
        # Add personal Zsh commands below.
        # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

        # setopt auto_pushd
        # setopt brace_ccl
        # setopt globdots

        # zstyle ':completion:*' completer _oldlist _expand _complete _correct _approximate
        # zstyle ':completion:*' menu select=long

        # alias -s py=python3
      '')
    ];

    # Add personal Home Manager options for Zsh below.
    # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

    # autosuggestion.enable = true;

    # autocd = true;

    # shellAliases = {
    #   python = "python3";
    # };
  };
}
