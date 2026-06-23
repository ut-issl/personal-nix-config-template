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
