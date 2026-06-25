{
  description = "A flake for my computers";

  inputs = {
    # NixOS 26.05 stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#valora'
    nixosConfigurations = {
      # Valora laptop
      valora = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./valora-configuration.nix ];
      };

      # Titania desktop
      titania = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./titania-configuration.nix ];
      };
    };
  };
}
