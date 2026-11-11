# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{
  description = "Checks that build every recipe against the shared configuration";

  inputs.root.url = "path:..";

  outputs =
    { root, ... }:
    let
      inherit (root.inputs.nixpkgs) lib;
      recipes = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
      fragments =
        name:
        map (file: ./. + "/${name}/${file}") (
          builtins.attrNames (
            lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".nix" file) (
              builtins.readDir (./. + "/${name}")
            )
          )
        );
    in
    {
      checks = lib.genAttrs (builtins.attrNames root.checks) (
        system:
        lib.mapAttrs (
          name: _:
          root.lib.mkCheck system {
            enableDesktop = true;
            includeUserModules = false;
            extraModules = fragments name;
          }
        ) recipes
      );
    };
}
