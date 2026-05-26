{
  nixConfig = {
    extra-experimental-features = ["pipe-operators"];
    allow-import-from-derivation = false;
    extra-substituters = ["https://cache.jadestar.dev"];
    extra-trusted-public-keys = ["cache.jadestar.dev-1:6nJfGkAZIQL8nj9kNzgXc1AJa+Eg/zv0YjZu8wX/aFM="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zsh-auto-notify = {
      flake = false;
      url = "github:MichaelAquilina/zsh-auto-notify";
    };

    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argononed = {
      url = "gitlab:DarkElvenAngel/argononed";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    den.url = "github:denful/den";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (inputs.import-tree [
          ./hosts
          ./modules
        ])
      ];
    };
}
