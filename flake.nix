# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{
  description = "Personal Home Manager configuration template for the ISSL Ubuntu environment";

  inputs = {
    issl.url = "github:ut-issl/issl-ubuntu-environment-setup/v0.8.8";
    nixpkgs.follows = "issl/nixpkgs";
    home-manager.follows = "issl/home-manager";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      issl,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import nixpkgs { inherit system; };
      requireEnv =
        name:
        let
          value = builtins.getEnv name;
        in
        if value != "" then
          value
        else
          throw "Environment variable ${name} is required. Run Home Manager with --impure.";
      defaultSystem =
        builtins.currentSystem
          or (throw "builtins.currentSystem is required. Run Home Manager with --impure.");
      mkHomeConfiguration =
        {
          system ? defaultSystem,
          username ? requireEnv "USER",
          homeDirectory ? requireEnv "HOME",
          enableDesktop ? false,
          includeUserModules ? true,
          extraModules ? [ ],
        }:
        let
          pkgs = mkPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            issl.homeModules.default
            (if includeUserModules then ./home-modules else ./home-modules/base.nix)
            {
              local.desktop.enable = enableDesktop;
              home = {
                inherit username homeDirectory;
                stateVersion = "26.05";
              };
            }
          ]
          ++ extraModules;
        };
      exampleNames = nixpkgs.lib.optionals (builtins.pathExists ./examples) (
        builtins.attrNames (
          nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./examples)
        )
      );
      exampleModules =
        name:
        let
          dir = ./examples + "/${name}";
        in
        map (file: dir + "/${file}") (
          builtins.attrNames (
            nixpkgs.lib.filterAttrs (file: type: type == "regular" && nixpkgs.lib.hasSuffix ".nix" file) (
              builtins.readDir dir
            )
          )
        );
    in
    {
      packages = forAllSystems (system: {
        default = home-manager.packages.${system}.home-manager;
        inherit (home-manager.packages.${system}) home-manager;
      });

      homeConfigurations = {
        user = mkHomeConfiguration { };
        user-desktop = mkHomeConfiguration { enableDesktop = true; };
      };

      formatter = forAllSystems (system: (mkPkgs system).nixfmt);

      checks = forAllSystems (
        system:
        let
          mkArgs =
            args:
            {
              inherit system;
              username = "user";
              homeDirectory = "/tmp/user-home";
            }
            // args;
          mkCheck = args: (mkHomeConfiguration (mkArgs args)).activationPackage;
          mkConfig = args: (mkHomeConfiguration (mkArgs args)).config;
        in
        {
          home = mkCheck { };
          home-desktop = mkCheck { enableDesktop = true; };
          home-bash-only = mkCheck { extraModules = [ { issl.zsh.enable = false; } ]; };
          home-desktop-gpu = mkCheck {
            enableDesktop = true;
            extraModules = [ { targets.genericLinux.gpu.enable = true; } ];
          };
          desktop-axis =
            assert nixpkgs.lib.assertMsg
              (!(mkConfig { }).local.desktop.enable && (mkConfig { enableDesktop = true; }).local.desktop.enable)
              "local.desktop.enable is switched by the configuration you apply, not by a definition in a module.";
            (mkPkgs system).emptyFile;
        }
        // nixpkgs.lib.genAttrs (map (name: "example-${name}") exampleNames) (
          check:
          mkCheck {
            enableDesktop = true;
            includeUserModules = false;
            extraModules = exampleModules (nixpkgs.lib.removePrefix "example-" check);
          }
        )
      );
    };
}
