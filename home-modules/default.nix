# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ lib, ... }:

let
  entries = builtins.readDir ./.;

  scaffolding = [
    "default.nix"
    "base.nix"
  ];

  strayModules = lib.attrNames (
    lib.filterAttrs (
      name: type: type != "directory" && !(builtins.elem name scaffolding) && lib.hasSuffix ".nix" name
    ) entries
  );
in
{
  imports = [
    ./base.nix
  ]
  ++
    lib.throwIf (strayModules != [ ])
      "home-modules/ takes one directory per module: move ${lib.concatStringsSep ", " strayModules} to <name>/<name>.nix"
      (
        lib.mapAttrsToList (
          name: _:
          let
            module = ./. + "/${name}/${name}.nix";
          in
          if builtins.pathExists module then
            module
          else
            throw "home-modules/${name}/ must contain ${name}.nix"
        ) (lib.filterAttrs (_: type: type == "directory") entries)
      );
}
