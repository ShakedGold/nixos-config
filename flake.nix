{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, plasma-manager, ... }:
  let
    # Replace with your username
    username = "shaked";

    # Replace with the fitting architecture
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

          # This should point to your home.nix path of course. For an example
          # of this see ./home.nix in this directory.
          home-manager.users."${username}" = import ./home.nix;
        }
      ];
    };
  };
}
