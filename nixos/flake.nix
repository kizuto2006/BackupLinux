{
  description = "Kizuto NixOS";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    noctalia.url = "github:noctalia-dev/noctalia";
    umbriel.url = "git+https://github.com/noctalia-dev/umbriel";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Genshin Launcher
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ 
        ./configuration.nix
        inputs.noctalia.nixosModules.default
        inputs.umbriel.nixosModules.default 
	inputs.noctalia-greeter.nixosModules.default

	inputs.aagl.nixosModules.default
      ];
    };
  };
}
