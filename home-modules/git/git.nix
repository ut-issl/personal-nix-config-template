# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
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

    settings = {
      # Personal identity:
      # user.name = "Your Name";
      # user.email = "you@example.com";

      # Add your personal Git configuration below.
      # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

      # alias = {
      #   ch = "checkout";
      #   cm = "commit";
      #   cr = "clone --recursive";
      #   st = "status";
      #   sw = "switch";
      # };

      # core.editor = "code --wait";

      # commit.verbose = true;

      # help.autocorrect = 1;

      # Use SSH for GitHub by default.
      # Comment out this block if you prefer HTTPS with Git Credential Manager or a personal access token.
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };

  };
}
