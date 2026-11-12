# Add this file as `home-modules/fonts/fonts.nix`.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.local.desktop.enable {
    fonts.fontconfig.enable = true;

    home.packages = [ pkgs.nerd-fonts.ubuntu-sans ];
  };
}
