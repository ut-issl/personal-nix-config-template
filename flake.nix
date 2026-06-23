{
  description = "Personal Home Manager configuration template for the ISSL Ubuntu environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    issl = {
      url = "github:ut-issl/issl-ubuntu-environment-setup";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      defaultSystem = builtins.currentSystem or "x86_64-linux";
      mkHomeConfiguration =
        {
          system ? defaultSystem,
          username ?
            let
              value = builtins.getEnv "USER";
            in
            if value != "" then value else "user",
          homeDirectory ?
            let
              value = builtins.getEnv "HOME";
            in
            if value != "" then value else "/tmp/user-home",
          enableZsh ? false,
        }:
        let
          pkgs = mkPkgs system;
          isslModule = issl.outPath + "/home-modules/main.nix";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit enableZsh;
          };
          modules = [
            isslModule
            ./home-modules/user.nix
            {
              home = {
                inherit username homeDirectory;
                stateVersion = "25.05";
              };
            }
          ];
        };
    in
    {
      packages = forAllSystems (system: {
        default = home-manager.packages.${system}.home-manager;
        inherit (home-manager.packages.${system}) home-manager;
      });

      homeConfigurations = {
        user = mkHomeConfiguration { enableZsh = false; };
        user-zsh = mkHomeConfiguration { enableZsh = true; };
      };

      formatter = forAllSystems (system: (mkPkgs system).nixfmt-rfc-style);

      checks = forAllSystems (system: {
        home = (mkHomeConfiguration { inherit system; }).activationPackage;
        home-zsh =
          (mkHomeConfiguration {
            inherit system;
            enableZsh = true;
          }).activationPackage;
      });
    };
}
