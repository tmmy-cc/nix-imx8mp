{
  description = "NixOS SD card image for nxp-imx8mp-evk with custom kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations = {
      acb = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-hardware.nixosModules.nxp-imx8mp-evk
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          {
            # Enable cross compilation
            #nixpkgs.buildPlatform = "x86_64-linux";
            #nixpkgs.crossSystem.system = "aarch64-linux";

            networking.useDHCP = true;
            services.openssh.enable = true;

            users.users.myuser = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [ "your-ssh-public-key" ];
            };

            system.stateVersion = "24.11"; # Adjust to your NixOS version
          }
        ];
      };
    };
  };
}

