# Add this file as `home-modules/pdf/pdf.nix`.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = lib.mkMerge [
    [ pkgs.qpdf ]
    (lib.mkIf config.local.desktop.enable [ pkgs.pdfarranger ])
  ];
}
